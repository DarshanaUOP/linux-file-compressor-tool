# File Manager Tool - Quick Start Guide

## Overview
A lightweight, user-friendly shell script for compressing files with metadata preservation and finding duplicate files. Features PEP 8 naming conventions and short command aliases.

## Files Included
- `file_manager_tool.sh` - Main executable script
- `REQUIREMENTS.md` - Detailed requirements, installation, and usage guide

## Quick Start

### 1. Make Script Executable
```bash
chmod +x file_manager_tool.sh
```

### 2. Run Operations (Short Form)

**Compress files:**
```bash
./file_manager_tool.sh c /path/to/source /path/to/destination
```

**Decompress files:**
```bash
./file_manager_tool.sh d /path/to/archive /path/to/restore
```

**Find duplicates:**
```bash
./file_manager_tool.sh f /path/to/scan
```

### 3. Alternative: Use Long Form Commands

```bash
./file_manager_tool.sh compress /path/to/source /path/to/destination
./file_manager_tool.sh decompress /path/to/archive /path/to/restore
./file_manager_tool.sh find-dup /path/to/scan
```

### 4. Get Help
```bash
./file_manager_tool.sh --help
```

## Command Reference

| Short | Long         | Arguments                      | Description                    |
|-------|--------------|--------------------------------|--------------------------------|
| `c`   | `compress`   | source_folder destination_folder | Compress with metadata         |
| `d`   | `decompress` | source_folder destination_folder | Decompress restoring metadata  |
| `f`   | `find-dup`   | source_folder                  | Find duplicate files           |

## Key Features
✓ **File-by-file compression** - Each file compressed individually
✓ **Preserves directory structure** - Relative paths maintained in destination
✓ Short command aliases (c, d, f) for quick operations
✓ Handles absolute and relative paths (including `../`)
✓ Preserves all file metadata (permissions, timestamps, ownership)
✓ Simple 2-3 argument command structure
✓ Color-coded output for easy reading
✓ Compression statistics for each file
✓ Automatic duplicate detection using MD5 checksums
✓ Timestamped manifests and reports
✓ Non-destructive operations
✓ PEP 8 naming conventions

## Requirements
- bash (4.0+)
- tar
- gzip
- md5sum (or md5 on macOS)
- find
- du

All these tools come pre-installed on most Linux/macOS systems.

## Example Usage

```bash
# Backup your documents (short form)
./file_manager_tool.sh c ~/Documents ~/Backups

# Find duplicate photos (short form)
./file_manager_tool.sh f ~/Pictures

# Restore from backup (short form)
./file_manager_tool.sh d ~/Backups ~/Restored

# Using long form if you prefer clarity
./file_manager_tool.sh compress ~/Documents ~/Backups
./file_manager_tool.sh find-dup ~/Pictures
```

## Optional: Create System-Wide Alias

```bash
# Add to ~/.bashrc or ~/.zshrc
alias fmtool='/path/to/file_manager_tool.sh'

# Then use it anywhere:
fmtool c ~/docs ~/backup
fmtool f ~/downloads
fmtool d ~/backup ~/restore
```

## Output Files

- **Compression**: Creates `.gz` files preserving directory structure, `.meta` files for metadata, plus `compression_manifest_YYYYMMDD_HHMMSS.txt`
  - Example: `source/sub/file.txt` becomes `dest/sub/file.txt.gz` and `dest/sub/file.txt.gz.meta`
- **Decompression**: Directory structure preserved from compression
- **Duplicates**: Creates `duplicates_report_YYYYMMDD_HHMMSS.txt` in source folder

For detailed documentation, see `REQUIREMENTS.md`.