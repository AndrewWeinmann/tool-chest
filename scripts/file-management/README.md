# File Management

## delete-old-files.sh

Deletes files and directories older than a specified number of days.

**Usage:**

```bash
./delete-old-files.sh [days=7] [path=.]
```

**Parameters:**

- `days`: Number of days (default: 7). Files modified more than this many days ago will be deleted.
- `path`: Target directory or file (default: current directory)

## rename-files-from-folder.sh

Renames all files in leaf folders to a numbered format: `folder_name 1.ext`, `folder_name 2.ext`, etc.

**Usage:**

```bash
./rename-files-from-folder.sh [ROOT_DIR]
```

**Parameters:**

- `ROOT_DIR`: Root directory to start renaming files (default: current directory)

**Notes:**

- A leaf folder is a directory that contains files but no subdirectories.
- Uses a two-phase rename to avoid collisions when target names already exist.

## set-extensions-from-filetype.sh

Sets file extensions based on MIME type detected by the `file` command. By default, it only adds extensions to files that have none. Use `--fix-mismatch` to rename files whose existing extension doesn't match the detected type.

**Usage:**

```bash
./set-extensions-from-filetype.sh [-r] [--dry-run] [--verbose] [--fix-mismatch] [DIR]
```

**Parameters:**

- `DIR`: Directory to scan (default: current directory)

**Options:**

- `-r`: Recurse into subdirectories
- `--dry-run`: Show planned renames without changing files
- `--verbose`: Print additional debugging information
- `--fix-mismatch`: Rename even if an extension exists but mismatches MIME (conservative for generic types)
