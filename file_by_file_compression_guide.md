# File-by-File Compression - Visual Example

## How It Works

### Before Compression (Source Directory)
```
~/documents/
├── report.pdf
├── data.csv
├── notes.txt
└── projects/
    ├── code.py
    └── config.json
```

### After Compression (Destination Directory)
```
~/backups/
├── report.pdf.gz
├── report.pdf.gz.meta
├── data.csv.gz
├── data.csv.gz.meta
├── notes.txt.gz
├── notes.txt.gz.meta
├── projects/
│   ├── code.py.gz
│   ├── code.py.gz.meta
│   ├── config.json.gz
│   └── config.json.gz.meta
└── compression_manifest_20260214_091500.txt
```

## Key Benefits of File-by-File Compression

### 1. **Individual File Access**
   - Extract only the files you need
   - No need to decompress entire archives
   - Faster access to specific files

### 2. **Better for Version Control**
   - Only recompress changed files
   - Easier to track what changed
   - More efficient incremental backups

### 3. **Fault Tolerance**
   - One corrupted file doesn't affect others
   - Failed compression doesn't lose all data
   - Partial recovery possible

### 4. **Flexible Usage**
   - Mix compressed and uncompressed files
   - Decompress selectively
   - Easy to automate

## Metadata Preservation

Each `.meta` file stores:
- Original file path
- File permissions (e.g., 755, 644)
- Modification time
- Original size
- Compressed size

Example `.meta` file content:
```
original_path=report.pdf
permissions=644
mtime=1708077900
original_size=2048000
compressed_size=512000
```

## Compression Manifest

The manifest file tracks all compressions:
```
# Compression Manifest
# Created: Sat Feb 14 09:15:00 UTC 2026
# Source: /home/user/documents
# Destination: /home/user/backups

report.pdf|2048000|512000|75%
data.csv|1024000|256000|75%
notes.txt|4096|2048|50%
projects/code.py|8192|4096|50%
projects/config.json|2048|1024|50%

# Summary
Total files: 5
Compressed: 5
Failed: 0
Original size: 3086336 bytes (2.94 MiB)
Compressed size: 775168 bytes (757.00 KiB)
Overall compression: 74%
```

## Usage Examples

### Compress Specific Folder
```bash
# Compress all files in ~/documents
./file_manager_tool.sh c ~/documents ~/backups

# Output:
✓ report.pdf (75% saved)
✓ data.csv (75% saved)
✓ notes.txt (50% saved)
✓ projects/code.py (50% saved)
✓ projects/config.json (50% saved)
```

### Decompress Everything
```bash
# Restore all files
./file_manager_tool.sh d ~/backups ~/restored

# Output:
✓ report.pdf
✓ data.csv
✓ notes.txt
✓ projects/code.py
✓ projects/config.json
```

### Selective Decompression
```bash
# Decompress just one file manually
gunzip ~/backups/report.pdf.gz

# The file will be restored to ~/backups/report.pdf
```

## Performance Characteristics

### Small Files (< 1KB)
- May increase in size due to gzip headers
- Still useful for organization
- Metadata preservation is primary benefit

### Medium Files (1KB - 100MB)
- Excellent compression ratios (30-80%)
- Fast compression/decompression
- Ideal use case

### Large Files (> 100MB)
- Good compression ratios (20-50%)
- Longer processing time
- Consider parallel processing for many files

## Comparison: File-by-File vs. Single Archive

| Feature                  | File-by-File | Single Archive |
|--------------------------|--------------|----------------|
| Individual file access   | ✅ Instant   | ❌ Extract all |
| Incremental backup       | ✅ Easy      | ❌ Difficult   |
| Fault tolerance          | ✅ High      | ⚠️ Low        |
| Compression ratio        | ⚠️ Good     | ✅ Excellent   |
| Number of files created  | ⚠️ Many     | ✅ One        |
| Metadata preservation    | ✅ Detailed  | ✅ Limited     |

## Best Practices

1. **Regular Backups**
   - Run compression daily/weekly
   - Keep multiple backup generations
   - Store backups on different drives

2. **Verify Integrity**
   - Check the compression manifest
   - Test random file decompressions
   - Monitor for failed compressions

3. **Clean Up**
   - Remove old backups periodically
   - Delete source files only after verification
   - Keep manifest files for records

4. **Organization**
   - Use dated backup folders
   - Keep related files together
   - Document your backup strategy

## Real-World Example

```bash
# Daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
SOURCE=~/important_documents
DEST=~/backups/backup_$DATE

# Create backup
./file_manager_tool.sh c $SOURCE $DEST

# Verify
if [ $? -eq 0 ]; then
    echo "Backup successful: $DEST"
    # Optional: email the manifest
    mail -s "Backup Complete" user@example.com < $DEST/compression_manifest_*.txt
else
    echo "Backup failed!"
    exit 1
fi

# Keep only last 7 days of backups
find ~/backups -maxdepth 1 -type d -name "backup_*" -mtime +7 -exec rm -rf {} \;
```

This approach gives you the best of both worlds: efficient compression with easy file access!
