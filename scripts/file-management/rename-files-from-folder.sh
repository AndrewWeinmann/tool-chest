#!/usr/bin/env bash

# Rename files in all leaf folders under a root directory.
# A "leaf" folder is a directory that contains files but no subdirectories.
# Files in each leaf folder are renamed to: "<folder_name> <index><.ext>"
# A two-phase rename is used to avoid collisions when target names already exist.

set -euo pipefail

# Enable nullglob to prevent glob patterns from expanding if no matches are found
# Enable dotglob to include hidden files (those starting with a dot) in glob expansions
shopt -s nullglob dotglob

TMP_SUFFIX=".tmp_renaming"

usage() {
  cat << 'USAGE'
Rename files in all leaf folders (folders with files but no subdirectories).

Usage:
  rename-files-from-folder.sh [ROOT_DIR]

Options:
  -h, --help   Show this help

Arguments:
  ROOT_DIR     Root directory to scan (default: current directory)
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

root_dir="${1:-$PWD}"

if [[ ! -d "$root_dir" ]]; then
  echo "Root path does not exist or is not a directory: $root_dir" >&2
  exit 1
fi

echo "Scanning root: $root_dir"

# Determine whether a directory is a leaf (no subdirectories, at least one file)
is_leaf_dir() {
  local dir="$1"
  # Check for any immediate subdirectories
  local has_subdir
  has_subdir=$(find "$dir" -mindepth 1 -maxdepth 1 -type d -print -quit 2> /dev/null || true)
  if [[ -n "$has_subdir" ]]; then
    return 1
  fi
  # Check for at least one file
  local has_file
  has_file=$(find "$dir" -mindepth 1 -maxdepth 1 -type f -print -quit 2> /dev/null || true)
  [[ -n "$has_file" ]]
}

# Process a single folder: rename files within it
process_folder() {
  local folder_path="$1"
  local folder_name
  folder_name="${folder_path##*/}"

  # Map temporary names to original filenames for clearer logging later.
  declare -A temp_orig=()

  echo "Processing: $folder_path"

  # Phase 1: rename all files to unique temporary names to avoid collisions.
  # Gather and sort files by name for deterministic temp assignment.
  mapfile -t files < <(for f in "$folder_path"/*; do [[ -f "$f" ]] && printf '%s\n' "$f"; done | sort)

  local index=1
  for file_path in "${files[@]}"; do
    local filename ext temp_name temp_path
    filename="${file_path##*/}"
    ext=""
    # Determine the extension (last suffix including the dot)
    if [[ "$filename" == *.* ]]; then
      # Handle dotfiles without extension (e.g., .bashrc) – treat as no extension
      if [[ "$filename" == .* && "$filename" != *.*.* ]]; then
        ext=""
      else
        ext=".${filename##*.}"
      fi
    fi

    temp_name="$folder_name $index$ext$TMP_SUFFIX"
    temp_path="$folder_path/$temp_name"

    if ! mv -- "$file_path" "$temp_path"; then
      echo "Error processing $folder_path: failed to rename $filename" >&2
      continue
    fi
    temp_orig["$temp_name"]="$filename"
    ((index++))
  done

  # Phase 2: rename temporary files to final names in sorted order,
  # re-enumerating indices starting at 1 and preserving original extensions.
  mapfile -t temp_basenames < <(for t in "$folder_path"/*"$TMP_SUFFIX"; do [[ -f "$t" ]] && printf '%s\n' "${t##*/}"; done | sort)

  index=1
  for temp_base in "${temp_basenames[@]}"; do
    local pre ext final_name orig_name
    pre="${temp_base%"$TMP_SUFFIX"}"
    if [[ "$pre" == *.* ]]; then
      ext=".${pre##*.}"
    else
      ext=""
    fi
    final_name="$folder_name $index$ext"

    orig_name="${temp_orig[$temp_base]:-$temp_base}"

    if mv -- "$folder_path/$temp_base" "$folder_path/$final_name"; then
      echo "Renamed: $orig_name → $final_name"
    else
      echo "Error processing $folder_path: failed to finalize $temp_base" >&2
    fi
    ((index++))
  done
}

# Walk all directories under root_dir and process leaf directories
while IFS= read -r -d '' dir; do
  if is_leaf_dir "$dir"; then
    process_folder "$dir"
  fi
done < <(find "$root_dir" -type d -print0)

exit 0
