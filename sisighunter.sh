#!/bin/bash

# List of required utilities
REQUIRED_UTILS=("file" "fsstat" "xxd" "mmls" "img_stat" "binwalk" "foremost")

# Function to check if utilities are installed
check_dependencies() {
    for cmd in "${REQUIRED_UTILS[@]}"; do
        command -v "$cmd" &>/dev/null
        if [ $? -ne 0 ]; then
            echo "Error: Required utility '$cmd' is not installed."
            exit 1
        fi
    done
}

# Check for arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <image.dd> [options]"
    echo "Options:"
    echo "  -info        Show what the script does"
    exit 1
fi

IMAGE="$1"
LOGFILE="${IMAGE%.*}_analysis.log"

# Info function - provides details about what the script does
info() {
    echo "This script performs forensic analysis on a disk image. It logs key details such as:" 
    echo " 1. General information about the image"
    echo " 2. File system analysis"
    echo " 3. Hex dump of the first few bytes"
    echo " 4. Partition layout"
    echo " 5. Embedded file extraction using binwalk"
    echo " 6. File carving using foremost"
    echo ""
    echo "Outputs are saved to a log file and any embedded files or carved files will be extracted."
}

# If -info flag is passed, show the documentation
if [ "$2" == "-info" ]; then
    info
    exit 0
fi

# Check if the required utilities are installed
check_dependencies

# Clear or create log file
echo "Forensic Analysis Log for $IMAGE" > "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"
echo "Date: $(date)" >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Log file format info
echo -e "\n=== File Command ===" >> "$LOGFILE"
file "$IMAGE" >> "$LOGFILE"
echo "Logged file command output" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# File system information
echo -e "\n=== fsstat ===" >> "$LOGFILE"
fsstat "$IMAGE" >> "$LOGFILE"
echo "Logged fsstat output" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# File system type force to FAT
echo -e "\n=== fsstat -t fat ===" >> "$LOGFILE"
fsstat -t fat "$IMAGE" >> "$LOGFILE"
echo "Logged fsstat with FAT type" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Hex dump (first 20 lines)
echo -e "\n=== Hex Dump (first 20 lines) ===" >> "$LOGFILE"
xxd "$IMAGE" | head -20 >> "$LOGFILE"
echo "Logged hex dump output" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Partition layout
echo -e "\n=== mmls ===" >> "$LOGFILE"
mmls "$IMAGE" >> "$LOGFILE"
echo "Logged mmls output" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Image statistics
echo -e "\n=== img_stat ===" >> "$LOGFILE"
img_stat "$IMAGE" >> "$LOGFILE"
echo "Logged img_stat output" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Basic image info
echo -e "\n=== ls -lh ===" >> "$LOGFILE"
ls -lh "$IMAGE" >> "$LOGFILE"
echo "Logged ls -lh output" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Binwalk for embedded file extraction
echo -e "\n=== Binwalk (Embedded Files Extraction) ===" >> "$LOGFILE"
binwalk --dd='.*' "$IMAGE" >> "$LOGFILE"
echo "Logged binwalk embedded files extraction" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Foremost for file carving
echo -e "\n=== Foremost (File Carving) ===" >> "$LOGFILE"
OUTPUT_DIR="${IMAGE%.*}_foremost_output"
mkdir -p "$OUTPUT_DIR"
foremost -i "$IMAGE" -o "$OUTPUT_DIR" >> "$LOGFILE"
echo "Logged foremost output" >> "$LOGFILE"
echo "File carving saved to $OUTPUT_DIR" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Summary of actions taken
echo -e "\n=== Summary of Actions Taken ===" >> "$LOGFILE"
echo "1. General file analysis with file command" >> "$LOGFILE"
echo "2. File system details using fsstat" >> "$LOGFILE"
echo "3. Hex dump for quick inspection" >> "$LOGFILE"
echo "4. Partition table information with mmls" >> "$LOGFILE"
echo "5. Image-level statistics with img_stat" >> "$LOGFILE"
echo "6. Embedded files extracted using binwalk" >> "$LOGFILE"
echo "7. Carved files extracted with foremost" >> "$LOGFILE"
echo "----------------------------------------" >> "$LOGFILE"
echo "Analysis saved to $LOGFILE"
