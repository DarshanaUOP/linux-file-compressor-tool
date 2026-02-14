#!/bin/bash

# File Compression & Duplicate Detection Script
# Preserves metadata during compression/decompression
# Version: 1.1 - File-by-file compression

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${GREEN}File Manager - Compress, Decompress, and Find Duplicates${NC}"
    echo ""
    echo "Usage:"
    echo "  $0 <operation> <source_folder> [destination_folder]"
    echo ""
    echo "Operations:"
    echo "  c, compress     - Compress files preserving metadata"
    echo "  d, decompress   - Decompress files restoring metadata"
    echo "  f, find-dup     - Find duplicate files and save report"
    echo ""
    echo "Examples:"
    echo "  $0 c /home/user/documents /home/user/backup"
    echo "  $0 d /home/user/backup /home/user/restored"
    echo "  $0 f /home/user/documents"
    exit 1
}

# Function to check if directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        echo -e "${RED}Error: Directory '$1' does not exist${NC}"
        exit 1
    fi
}

# Function to create directory if it doesn't exist
create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo -e "${GREEN}Created directory: $1${NC}"
    fi
}

# Function to compress files
compress_files() {
    local source="$1"
    local destination="$2"
    
    # Convert to absolute paths to handle relative paths correctly
    source=$(cd "$source" && pwd)
    destination=$(mkdir -p "$destination" && cd "$destination" && pwd)
    
    check_directory "$source"
    
    echo -e "${GREEN}Starting file-by-file compression...${NC}"
    echo "Source: $source"
    echo "Destination: $destination"
    echo ""
    
    local total_files=0
    local compressed_files=0
    local failed_files=0
    local total_original_size=0
    local total_compressed_size=0
    
    # Create a manifest file to track all compressed files
    local manifest_file="$destination/compression_manifest_$(date +%Y%m%d_%H%M%S).txt"
    echo "# Compression Manifest" > "$manifest_file"
    echo "# Created: $(date)" >> "$manifest_file"
    echo "# Source: $source" >> "$manifest_file"
    echo "# Destination: $destination" >> "$manifest_file"
    echo "" >> "$manifest_file"
    
    # Find all files recursively and compress each one
    while IFS= read -r -d '' filepath; do
        ((total_files++))
        
        # Get relative path from source directory (remove source prefix)
        local rel_path="${filepath#$source/}"
        
        # Create corresponding directory structure in destination
        local dest_dir="$destination/$(dirname "$rel_path")"
        mkdir -p "$dest_dir" > /dev/null 2>&1
        
        # Compressed file path (maintain relative structure)
        local compressed_path="$destination/${rel_path}.gz"
        
        # Get file size before compression (cross-platform)
        local original_size=$(stat -c%s "$filepath" 2>/dev/null || stat -f%z "$filepath" 2>/dev/null)
        
        # Get file metadata (cross-platform)
        local file_perms=$(stat -c%a "$filepath" 2>/dev/null || stat -f%Lp "$filepath" 2>/dev/null)
        local file_mtime=$(stat -c%Y "$filepath" 2>/dev/null || stat -f%m "$filepath" 2>/dev/null)
        
        # Compress the file preserving attributes
        if gzip -c "$filepath" > "$compressed_path" 2>/dev/null; then
            # Get compressed size
            local compressed_size=$(stat -c%s "$compressed_path" 2>/dev/null || stat -f%z "$compressed_path" 2>/dev/null)
            
            # Store metadata in separate file
            local meta_file="${compressed_path}.meta"
            echo "original_path=$rel_path" > "$meta_file"
            echo "permissions=$file_perms" >> "$meta_file"
            echo "mtime=$file_mtime" >> "$meta_file"
            echo "original_size=$original_size" >> "$meta_file"
            echo "compressed_size=$compressed_size" >> "$meta_file"
            
            # Copy original file permissions to compressed file
            chmod "$file_perms" "$compressed_path" 2>/dev/null
            
            ((compressed_files++))
            total_original_size=$((total_original_size + original_size))
            total_compressed_size=$((total_compressed_size + compressed_size))
            
            # Calculate compression ratio
            local ratio=0
            if [ $original_size -gt 0 ]; then
                ratio=$((100 - (compressed_size * 100 / original_size)))
            fi
            
            echo -e "${GREEN}✓${NC} $rel_path (${ratio}% saved)"
            echo "$rel_path|$original_size|$compressed_size|$ratio%" >> "$manifest_file"
        else
            ((failed_files++))
            echo -e "${RED}✗${NC} Failed to compress: $rel_path"
            echo "FAILED|$rel_path" >> "$manifest_file"
        fi
    done < <(find "$source" -type f -print0)
    
    # Calculate overall statistics
    local overall_ratio=0
    if [ $total_original_size -gt 0 ]; then
        overall_ratio=$((100 - (total_compressed_size * 100 / total_original_size)))
    fi
    
    # Convert bytes to human readable format
    local hr_original=$(echo "$total_original_size" | awk '{
        if ($1 >= 1073741824) printf "%.2f GiB", $1/1073741824;
        else if ($1 >= 1048576) printf "%.2f MiB", $1/1048576;
        else if ($1 >= 1024) printf "%.2f KiB", $1/1024;
        else printf "%d B", $1;
    }')
    local hr_compressed=$(echo "$total_compressed_size" | awk '{
        if ($1 >= 1073741824) printf "%.2f GiB", $1/1073741824;
        else if ($1 >= 1048576) printf "%.2f MiB", $1/1048576;
        else if ($1 >= 1024) printf "%.2f KiB", $1/1024;
        else printf "%d B", $1;
    }')
    
    # Summary
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}Compression Summary${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo "Total files found: $total_files"
    echo "Successfully compressed: $compressed_files"
    echo "Failed: $failed_files"
    echo "Original size: $hr_original"
    echo "Compressed size: $hr_compressed"
    echo "Space saved: ${overall_ratio}%"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo ""
    echo "Manifest saved to: $manifest_file"
    
    # Add summary to manifest
    echo "" >> "$manifest_file"
    echo "# Summary" >> "$manifest_file"
    echo "Total files: $total_files" >> "$manifest_file"
    echo "Compressed: $compressed_files" >> "$manifest_file"
    echo "Failed: $failed_files" >> "$manifest_file"
    echo "Original size: $total_original_size bytes ($hr_original)" >> "$manifest_file"
    echo "Compressed size: $total_compressed_size bytes ($hr_compressed)" >> "$manifest_file"
    echo "Overall compression: ${overall_ratio}%" >> "$manifest_file"
}

# Function to decompress files
decompress_files() {
    local source="$1"
    local destination="$2"
    
    # Convert to absolute paths
    source=$(cd "$source" && pwd)
    destination=$(mkdir -p "$destination" && cd "$destination" && pwd)
    
    check_directory "$source"
    
    echo -e "${GREEN}Starting file-by-file decompression...${NC}"
    echo "Source: $source"
    echo "Destination: $destination"
    echo ""
    
    local total_files=0
    local decompressed_files=0
    local failed_files=0
    
    # Find all .gz files recursively in source directory (excluding .meta files)
    while IFS= read -r -d '' gz_file; do
        ((total_files++))
        
        # Get relative path from source directory
        local rel_gz_path="${gz_file#$source/}"
        
        # Check for metadata file
        local meta_file="${gz_file}.meta"
        
        if [ -f "$meta_file" ]; then
            # Read original path from metadata
            local original_path=$(grep "^original_path=" "$meta_file" | cut -d'=' -f2-)
            local original_perms=$(grep "^permissions=" "$meta_file" | cut -d'=' -f2-)
            local original_mtime=$(grep "^mtime=" "$meta_file" | cut -d'=' -f2-)
            
            # Create corresponding directory structure in destination
            local dest_dir="$destination/$(dirname "$original_path")"
            mkdir -p "$dest_dir" > /dev/null 2>&1
            
            # Decompressed file path (restore original structure)
            local decompressed_path="$destination/$original_path"
            
            # Decompress the file
            if gunzip -c "$gz_file" > "$decompressed_path" 2>/dev/null; then
                # Restore permissions if available
                if [ -n "$original_perms" ]; then
                    chmod "$original_perms" "$decompressed_path" 2>/dev/null
                fi
                
                # Restore modification time if available (using timestamp)
                if [ -n "$original_mtime" ]; then
                    touch -t "$(date -d @$original_mtime +%Y%m%d%H%M.%S 2>/dev/null)" "$decompressed_path" 2>/dev/null || \
                    touch -r "$gz_file" "$decompressed_path" 2>/dev/null
                fi
                
                ((decompressed_files++))
                echo -e "${GREEN}✓${NC} $original_path"
            else
                ((failed_files++))
                echo -e "${RED}✗${NC} Failed to decompress: $rel_gz_path"
            fi
        else
            # No metadata file - remove .gz extension and use relative path
            local original_name="${rel_gz_path%.gz}"
            
            # Create corresponding directory structure in destination
            local dest_dir="$destination/$(dirname "$original_name")"
            mkdir -p "$dest_dir" > /dev/null 2>&1
            
            local decompressed_path="$destination/$original_name"
            
            # Decompress the file
            if gunzip -c "$gz_file" > "$decompressed_path" 2>/dev/null; then
                # Copy permissions from compressed file
                chmod --reference="$gz_file" "$decompressed_path" 2>/dev/null || \
                    chmod 644 "$decompressed_path" 2>/dev/null
                
                ((decompressed_files++))
                echo -e "${GREEN}✓${NC} $original_name"
            else
                ((failed_files++))
                echo -e "${RED}✗${NC} Failed to decompress: $rel_gz_path"
            fi
        fi
    done < <(find "$source" -type f -name "*.gz" ! -name "*.meta" -print0)
    
    # Summary
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}Decompression Summary${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo "Total .gz files found: $total_files"
    echo "Successfully decompressed: $decompressed_files"
    echo "Failed: $failed_files"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo ""
    echo "Files restored to: $destination"
}

# Function to find duplicate files
find_duplicates() {
    local source="$1"
    
    check_directory "$source"
    
    echo -e "${GREEN}Scanning for duplicate files...${NC}"
    echo "Source: $source"
    echo ""
    
    # Create temporary file for checksums
    local temp_file=$(mktemp)
    local output_file="$source/duplicates_report_$(date +%Y%m%d_%H%M%S).txt"
    
    # Find all files and calculate MD5 checksums
    echo "Calculating checksums..."
    find "$source" -type f -exec md5sum {} \; | sort > "$temp_file"
    
    # Find duplicates based on checksum
    local duplicates_found=false
    echo "# Duplicate Files Report" > "$output_file"
    echo "# Generated: $(date)" >> "$output_file"
    echo "# Source: $source" >> "$output_file"
    echo "" >> "$output_file"
    
    local current_hash=""
    local current_group=()
    
    while IFS= read -r line; do
        local hash=$(echo "$line" | awk '{print $1}')
        local filepath=$(echo "$line" | cut -d' ' -f3-)
        
        if [ "$hash" = "$current_hash" ]; then
            current_group+=("$filepath")
        else
            # Process previous group if it has duplicates
            if [ ${#current_group[@]} -gt 1 ]; then
                duplicates_found=true
                echo "Duplicate Group (Hash: $current_hash):" >> "$output_file"
                for file in "${current_group[@]}"; do
                    local size=$(du -h "$file" 2>/dev/null | cut -f1)
                    echo "  - $file (Size: $size)" >> "$output_file"
                done
                echo "" >> "$output_file"
            fi
            
            # Start new group
            current_hash="$hash"
            current_group=("$filepath")
        fi
    done < "$temp_file"
    
    # Process last group
    if [ ${#current_group[@]} -gt 1 ]; then
        duplicates_found=true
        echo "Duplicate Group (Hash: $current_hash):" >> "$output_file"
        for file in "${current_group[@]}"; do
            local size=$(du -h "$file" 2>/dev/null | cut -f1)
            echo "  - $file (Size: $size)" >> "$output_file"
        done
        echo "" >> "$output_file"
    fi
    
    # Clean up
    rm -f "$temp_file"
    
    if [ "$duplicates_found" = true ]; then
        echo -e "${YELLOW}Duplicates found!${NC}"
        echo "Report saved to: $output_file"
        echo ""
        echo "Preview:"
        head -n 20 "$output_file"
    else
        echo -e "${GREEN}No duplicates found!${NC}"
        echo "All files are unique." > "$output_file"
        echo "Report saved to: $output_file"
    fi
}

# Main script logic
main() {
    # Check if at least operation is provided
    if [ $# -lt 1 ]; then
        usage
    fi
    
    local operation="$1"
    
    case "$operation" in
        c|compress)
            if [ $# -ne 3 ]; then
                echo -e "${RED}Error: compress requires source and destination folders${NC}"
                usage
            fi
            compress_files "$2" "$3"
            ;;
        d|decompress)
            if [ $# -ne 3 ]; then
                echo -e "${RED}Error: decompress requires source and destination folders${NC}"
                usage
            fi
            decompress_files "$2" "$3"
            ;;
        f|find-dup|find-duplicates)
            if [ $# -ne 2 ]; then
                echo -e "${RED}Error: find-duplicates requires source folder${NC}"
                usage
            fi
            find_duplicates "$2"
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            echo -e "${RED}Error: Unknown operation '$operation'${NC}"
            usage
            ;;
    esac
}

# Run main function
main "$@"