#!/usr/bin/env bash

# Delete files older than N days within a target and prune directories left empty.
# Defaults to 7 days and the current directory if no arguments are provided.

set -euo pipefail

usage() {
  cat << 'USAGE'
Delete files older than N days and prune empty directories.

Usage:
    delete-old-files.sh [days=7] [path=.]

Options:
    -h, --help   Show this help

Arguments:
    days         Non-negative integer; default 7
    path         Target file or directory; default current directory
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

days=${1:-7}
target=${2:-.}

# validate days
if ! printf '%s' "$days" | grep -Eq '^[0-9]+$'; then
  printf 'Error: days must be a non-negative integer\n' >&2
  exit 2
fi

# basic safety checks
if [ -z "$target" ]; then
  printf 'Error: empty target path\n' >&2
  exit 3
fi

# Normalize target path
if command -v realpath > /dev/null 2>&1; then
  target=$(realpath "$target")
fi

# Prevent operating on root directory
if [ "$target" = "/" ]; then
  printf 'Refusing to operate on root /\n' >&2
  exit 4
fi

# Check that target exists
if [ ! -e "$target" ]; then
  printf 'Error: target does not exist: %s\n' "$target" >&2
  exit 5
fi

# Delete files older than N days, then prune directories left empty by removals.
printf 'Target: %s (days: %d)\n' "$target" "$days"
printf 'Scanning for files older than %d day(s)...\n' "$days"

if [ -d "$target" ]; then
  # Count files to be deleted
  files_deleted=$(find "$target" -type f -mtime +"$days" -print | wc -l)

  # Delete files
  find "$target" -type f -mtime +"$days" -delete

  # Count and delete empty directories
  dirs_deleted=$(find "$target" -depth -type d -empty ! -path "$target" -print | wc -l)
  find "$target" -depth -type d -empty ! -path "$target" -delete

  printf '\nSummary:\n'
  printf '  Files deleted:       %d\n' "$files_deleted"
  printf '  Empty dirs removed:  %d\n' "$dirs_deleted"
else
  # Single file target
  if [ -f "$target" ] && [ "$(find "$target" -maxdepth 0 -mtime +"$days")" ]; then
    find "$target" -maxdepth 0 -type f -mtime +"$days" -delete
    printf '\nSummary:\n'
    printf '  File deleted:        1\n'
  else
    printf '\nSummary:\n'
    printf '  File deleted:        0 (does not meet age criteria)\n'
  fi
fi
