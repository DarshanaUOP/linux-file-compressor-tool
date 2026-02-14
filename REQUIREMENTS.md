# File Manager Tool - Requirements & Setup

## System Requirements

### Operating System
- Linux (Ubuntu, Debian, CentOS, RHEL, etc.)
- macOS
- Windows (with Git Bash, WSL, or Cygwin)

### Required Tools
The following tools must be installed on your system:

1. **bash** (version 4.0 or higher)
   - Usually pre-installed on Linux/macOS
   - Check: `bash --version`

2. **tar** (GNU tar recommended)
   - Used for archiving and compression
   - Check: `tar --version`
   - Install (Ubuntu/Debian): `sudo apt-get install tar`
   - Install (CentOS/RHEL): `sudo yum install tar`
   - Install (macOS): Pre-installed

3. **gzip** 
   - Used for compression
   - Check: `gzip --version`
   - Install (Ubuntu/Debian): `sudo apt-get install gzip`
   - Install (CentOS/RHEL): `sudo yum install gzip`
   - Install (macOS): Pre-installed

4. **md5sum** (for duplicate detection)
   - Check: `md5sum --version`
   - Install (Ubuntu/Debian): Pre-installed (part of coreutils)
   - Install (CentOS/RHEL): Pre-installed (part of coreutils)
   - Install (macOS): Use `md5` instead (script auto-detects)

5. **find** 
   - Check: `find --version`
   - Usually pre-installed on all Unix-like systems

6. **du** (disk usage utility)
   - Check: `du --version`
   - Usually pre-installed on all Unix-like systems

### Optional Tools
- **tree** - For viewing directory structure (optional)
  - Install (Ubuntu/Debian): `sudo apt-get install tree`

## Installation

### Step 1: Download the Script
Save the `file_manager_tool.sh` script to your preferred location.

### Step 2: Make the Script Executable
```bash
chmod +x file_manager_tool.sh
```

### Step 3: (Optional) Add to PATH
To run the script from anywhere, you can:

**Option A: Create a symbolic link**
```bash
sudo ln -s /path/to/file_manager_tool.sh /usr/local/bin/fmtool
```

**Option B: Move to a bin directory**
```bash
sudo mv file_manager_tool.sh /usr/local/bin/fmtool
```

**Option C: Add to your PATH in ~/.bashrc**
```bash
echo 'export PATH="$PATH:/path/to/script/directory"' >> ~/.bashrc
source ~/.bashrc
```

## Quick Installation (Ubuntu/Debian)

```bash
# Install all required dependencies
sudo apt-get update
sudo apt-get install -y tar gzip coreutils findutils

# Make script executable
chmod +x file_manager_tool.sh

# Optional: Move to system bin with short name
sudo cp file_manager_tool.sh /usr/local/bin/fmtool
```

## Quick Installation (CentOS/RHEL)

```bash
# Install all required dependencies
sudo yum install -y tar gzip coreutils findutils

# Make script executable
chmod +x file_manager_tool.sh

# Optional: Move to system bin with short name
sudo cp file_manager_tool.sh /usr/local/bin/fmtool
```

## Quick Installation (macOS)

```bash
# All tools are pre-installed on macOS
# Just make the script executable
chmod +x file_manager_tool.sh

# Optional: Move to user bin with short name
cp file_manager_tool.sh /usr/local/bin/fmtool
```

## Usage

### Basic Syntax
```bash
./file_manager_tool.sh <operation> <source_folder> [destination_folder]
```

### Operations

Short and long forms are both supported for user convenience:

| Short | Long           | Description                                    |
|-------|----------------|------------------------------------------------|
| `c`   | `compress`     | Compress files preserving metadata             |
| `d`   | `decompress`   | Decompress files restoring metadata            |
| `f`   | `find-dup`     | Find duplicate files and save report           |

#### 1. Compress Files
Compresses each file individually while preserving metadata (permissions, timestamps, ownership).

```bash
./file_manager_tool.sh c <source_folder> <destination_folder>
# OR
./file_manager_tool.sh compress <source_folder> <destination_folder>
```

**Example:**
```bash
./file_manager_tool.sh c ~/documents ~/backups
```

**What it does:**
- Compresses each file individually with gzip (.gz format)
- Preserves directory structure
- Preserves all file metadata in separate .meta files
- Creates a compression manifest with statistics
- Shows compression ratio for each file
- Displays overall compression summary

#### 2. Decompress Files
Decompresses individually compressed files and restores all metadata.

```bash
./file_manager_tool.sh d <source_folder> <destination_folder>
# OR
./file_manager_tool.sh decompress <source_folder> <destination_folder>
```

**Example:**
```bash
./file_manager_tool.sh d ~/backups ~/restored
```

**What it does:**
- Finds all .gz files in source folder recursively
- Decompresses each file individually
- Restores original directory structure
- Restores all original metadata from .meta files
- Shows progress for each file
- Displays summary statistics

#### 3. Find Duplicates
Scans a directory for duplicate files based on content (MD5 hash).

```bash
./file_manager_tool.sh f <source_folder>
# OR
./file_manager_tool.sh find-dup <source_folder>
```

**Example:**
```bash
./file_manager_tool.sh f ~/documents
```

**What it does:**
- Scans all files recursively
- Calculates MD5 checksums
- Groups identical files
- Creates a timestamped report: `duplicates_report_YYYYMMDD_HHMMSS.txt`
- Shows file sizes for each duplicate

### Help
```bash
./file_manager_tool.sh --help
```

## Example Workflows

### Workflow 1: Backup Important Documents
```bash
# Compress documents (short form)
./file_manager_tool.sh c ~/documents /mnt/backup

# Later, restore them (short form)
./file_manager_tool.sh d /mnt/backup ~/restored_documents
```

### Workflow 2: Clean Up Storage
```bash
# Find duplicates (short form)
./file_manager_tool.sh f ~/downloads

# Review the duplicates report
cat ~/downloads/duplicates_report_*.txt

# Manually remove unwanted duplicates
# Then compress the cleaned directory
./file_manager_tool.sh c ~/downloads /mnt/backup
```

### Workflow 3: Archive Old Projects
```bash
# Find and remove duplicates first
./file_manager_tool.sh f ~/projects

# Compress the project directory
./file_manager_tool.sh c ~/projects /mnt/archives
```

### Workflow 4: Using Short Commands for Speed
```bash
# Quick backup
fmtool c ~/work ~/backup_$(date +%Y%m%d)

# Quick duplicate scan
fmtool f ~/photos

# Quick restore
fmtool d ~/backup_20260214 ~/restore
```

## Features

### Metadata Preservation
The script preserves:
- ✓ File permissions (read, write, execute)
- ✓ File ownership (user and group)
- ✓ Timestamps (modification time, access time)
- ✓ Directory structure
- ✓ Symbolic links
- ✓ File attributes

### User-Friendly Design
- File-by-file compression (each file compressed individually)
- Simple command syntax with short aliases (c, d, f)
- Color-coded output (green for success, red for errors, yellow for warnings)
- Clear progress messages for each file
- Detailed compression statistics
- Detailed error messages
- Timestamped manifests and reports
- Automatic directory creation
- PEP 8 style naming conventions

### Safety Features
- Validates directories before operations
- Checks for required tools
- Non-destructive operations (original files are never deleted)
- Creates separate metadata files
- Generates detailed reports

## Troubleshooting

### "Permission denied" error
```bash
# Make sure the script is executable
chmod +x file_manager_tool.sh

# If accessing system directories, use sudo
sudo ./file_manager_tool.sh c /var/log ~/backup
```

### "Directory does not exist" error
- Check that the source directory path is correct
- Use absolute paths for clarity
- Destination directories are created automatically

### "No .tar.gz archives found" (during decompress)
- Ensure the source directory contains .tar.gz files
- Check that files have the correct extension

### MD5 command not found (macOS)
The script automatically handles this - macOS uses `md5` instead of `md5sum`.

## Performance Notes

- **Compression speed**: Depends on file size and quantity. Typical: 10-50 MB/s
- **Duplicate detection**: Large directories may take time. Progress is shown.
- **Memory usage**: Minimal - processes files sequentially

## Output Files

### Compression Output
- `filename.gz` - Individual compressed files (one per source file)
- `filename.gz.meta` - Metadata file for each compressed file
- `compression_manifest_YYYYMMDD_HHMMSS.txt` - Manifest with compression statistics

### Duplicate Detection Output
- `duplicates_report_YYYYMMDD_HHMMSS.txt` - Duplicate files report

## Naming Conventions

All files follow PEP 8 style naming (lowercase with underscores):
- Script: `file_manager_tool.sh`
- Output files: `duplicates_report_*.txt`, `archive_*.tar.gz`
- Functions: `compress_files()`, `find_duplicates()`

## License
This script is provided as-is for personal and commercial use.

## Version
1.2 - File-by-file compression with individual metadata preservation
