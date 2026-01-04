#!/usr/bin/env bash

# Set file extensions based on MIME type detected by `file`.
# - Uses `file --mime-type` to determine the canonical extension.
# - Supports dry-run mode and recursive scanning.
# - Skips symlinks and directories.

set -o pipefail

usage() {
  cat << 'USAGE'
Set file extensions based on MIME type detected by `file`.

Usage:
  set-extensions-from-filetype.sh [-r] [--dry-run] [--verbose] [--fix-mismatch] [DIR]

Options:
  -r             Recurse into subdirectories
  --dry-run      Show planned renames without changing files
  --verbose      Print additional debugging information
  --fix-mismatch Rename files even if an extension exists but doesn't match MIME
  -h, --help     Show this help

Arguments:
  DIR           Directory to scan (default: current directory)

Notes:
  - Only renames regular files.
  - If target name exists, appends a numeric suffix to avoid collisions.
  - Unknown MIME types are skipped.
USAGE
}

verbose=false
dry_run=false
recursive=false
fix_mismatch=false

# Logging
log() {
  printf '%s\n' "$*"
}

# Verbose logging
vlog() {
  if $verbose; then
    printf '[verbose] %s\n' "$*"
  fi
}

# Map MIME type to a preferred extension (lowercase, without leading dot).
ext_from_mime() {
  case "$1" in
    # Text / Code
    text/plain) echo "txt" ;;
    text/markdown) echo "md" ;;
    text/html) echo "html" ;;
    text/css) echo "css" ;;
    text/csv) echo "csv" ;;
    application/javascript | text/javascript) echo "js" ;;
    application/json) echo "json" ;;
    application/xml | text/xml) echo "xml" ;;
    application/yaml | text/yaml | application/x-yaml) echo "yaml" ;;

    # Images
    image/jpeg) echo "jpg" ;;
    image/png) echo "png" ;;
    image/gif) echo "gif" ;;
    image/webp) echo "webp" ;;
    image/bmp) echo "bmp" ;;
    image/tiff) echo "tif" ;;
    image/svg+xml) echo "svg" ;;

    # Documents / Archives
    application/pdf) echo "pdf" ;;
    application/zip) echo "zip" ;;
    application/x-7z-compressed) echo "7z" ;;
    application/x-rar | application/x-rar-compressed) echo "rar" ;;
    application/x-tar) echo "tar" ;;
    application/gzip) echo "gz" ;;
    application/x-bzip2) echo "bz2" ;;
    application/x-xz) echo "xz" ;;

    # Misc
    application/octet-stream) echo "bin" ;;
    application/x-executable) echo "bin" ;;

    *) return 1 ;;
  esac
}

# Safely compute a new, non-colliding path if target exists.
safe_target_path() {
  local dir base ext candidate n
  dir=$1
  base=$2
  ext=$3

  if [[ -z $ext ]]; then
    candidate="$dir/$base"
  else
    candidate="$dir/$base.$ext"
  fi

  if [[ ! -e "$candidate" ]]; then
    printf '%s\n' "$candidate"
    return 0
  fi

  n=1
  while :; do
    if [[ -z $ext ]]; then
      candidate="$dir/${base}_$n"
    else
      candidate="$dir/${base}_$n.$ext"
    fi
    [[ ! -e "$candidate" ]] && {
      printf '%s\n' "$candidate"
      return 0
    }
    n=$((n + 1))
  done
}

# Normalize extension to lowercase
normalize_ext() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

# Process a single file: determine desired extension and rename if needed.
process_file() {
  local path dir name stem cur_ext mime wanted_ext target target_name
  path=$1

  # Skip non-regular files
  [[ -f "$path" ]] || {
    vlog "Skipping non-regular: $path"
    return
  }
  # Skip symlinks
  [[ -L "$path" ]] && {
    vlog "Skipping symlink: $path"
    return
  }

  dir=$(dirname -- "$path")
  name=$(basename -- "$path")

  # Determine current extension (handle dotfiles gracefully)
  if [[ "$name" == .* && "$name" != *.* ]]; then
    stem="$name"
    cur_ext=""
  else
    if [[ "$name" == *.* ]]; then
      stem="${name%.*}"
      cur_ext="${name##*.}"
    else
      stem="$name"
      cur_ext=""
    fi
  fi

  # Get MIME type
  mime=$(file --mime-type -b -- "$path" 2> /dev/null || true)
  if [[ -z "$mime" ]]; then
    vlog "No MIME from file(1): $path"
    return
  fi

  # If file already has an extension and we're not fixing mismatches, skip
  if [[ -n "$cur_ext" && $fix_mismatch == false ]]; then
    vlog "Has extension, skipping (use --fix-mismatch to force): $path"
    return
  fi

  # Get desired extension from MIME
  if ! wanted_ext=$(ext_from_mime "$mime"); then
    vlog "Unknown MIME ($mime), skipping: $path"
    return
  fi

  cur_ext=$(normalize_ext "$cur_ext")
  wanted_ext=$(normalize_ext "$wanted_ext")

  # Don't force generic or ambiguous types if extension exists
  if [[ -n "$cur_ext" && $fix_mismatch == true ]]; then
    case "$mime" in
      text/plain | application/octet-stream)
        vlog "Generic MIME ($mime), leaving existing extension: $path"
        return
        ;;
    esac
  fi

  # If already correct, skip
  if [[ -n "$cur_ext" && "$cur_ext" == "$wanted_ext" ]]; then
    vlog "Extension already correct ($wanted_ext): $path"
    return
  fi

  # If no extension and mapping is too generic, be conservative
  if [[ -z "$cur_ext" ]]; then
    case "$mime" in
      application/octet-stream | application/x-executable)
        vlog "Generic binary MIME ($mime), skipping: $path"
        return
        ;;
    esac
  fi

  # Build target path
  if [[ -z "$wanted_ext" ]]; then
    target=$(safe_target_path "$dir" "$stem" "")
  else
    target=$(safe_target_path "$dir" "$stem" "$wanted_ext")
  fi
  target_name=$(basename -- "$target")

  if $dry_run; then
    log "DRY-RUN: would rename: $name -> $target_name (MIME: $mime)"
  else
    log "Renaming: $name -> $target_name (MIME: $mime)"
    mv -- "$path" "$target"
  fi
}

# Scan directory (optionally recursively) and process files.
scan_dir() {
  local base
  base=$1
  if $recursive; then
    # Use NUL-separated paths to safely handle spaces/newlines.
    find "$base" -type f -print0 | while IFS= read -r -d '' f; do
      process_file "$f"
    done
  else
    # Only the top-level of the directory
    while IFS= read -r -d '' f; do
      process_file "$f"
    done < <(find "$base" -maxdepth 1 -type f -print0)
  fi
}

# Main entry point
main() {
  local dir="."

  # Parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -r)
        recursive=true
        shift
        ;;
      --dry-run)
        dry_run=true
        shift
        ;;
      --verbose)
        verbose=true
        shift
        ;;
      --fix-mismatch)
        fix_mismatch=true
        shift
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "Unknown option: $1" >&2
        usage
        exit 2
        ;;
      *)
        dir="$1"
        shift
        ;;
    esac
  done

  if [[ ! -d "$dir" ]]; then
    echo "Not a directory: $dir" >&2
    exit 1
  fi

  vlog "Scanning directory: $dir (recursive=$recursive, dry_run=$dry_run)"
  scan_dir "$dir"
}

main "$@"
