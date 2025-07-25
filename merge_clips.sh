#!/bin/bash

# Script to merge all video clips into a single video file
# Usage: ./merge_clips.sh

# Source directory containing the clips
CLIPS_DIR="output/observation.images.laptop.h264/merge"

# Output merged video file
OUTPUT_FILE="output/observation.images.laptop.h264/merged_video.mp4"

# Temporary file list for ffmpeg
TEMP_FILELIST="temp_filelist.txt"

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install ffmpeg first."
    exit 1
fi

# Check if clips directory exists
if [ ! -d "$CLIPS_DIR" ]; then
    echo "Error: Clips directory '$CLIPS_DIR' does not exist."
    exit 1
fi

echo "Starting video merging process..."
echo "Source directory: $CLIPS_DIR"
echo "Output file: $OUTPUT_FILE"
echo ""

# Count total clips
total_clips=$(find "$CLIPS_DIR" -name "output_*.mp4" | wc -l)
echo "Found $total_clips clips to merge"

if [ "$total_clips" -eq 0 ]; then
    echo "No video clips found in $CLIPS_DIR"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Create a file list for ffmpeg (sorted by output number)
echo "Creating file list for merging..."
> "$TEMP_FILELIST"  # Clear the file first!
find "$CLIPS_DIR" -name "output_*.mp4" | sort | while read -r file; do
    echo "file '$file'" >> "$TEMP_FILELIST"
done

# Check if file list was created successfully
if [ ! -s "$TEMP_FILELIST" ]; then
    echo "Error: Could not create file list"
    exit 1
fi

echo "File list created with $(wc -l < "$TEMP_FILELIST") files"
echo ""

# Merge all clips using ffmpeg concat demuxer
echo "Merging clips into single video file..."
echo "This may take a while depending on the number and size of clips..."

ffmpeg -f concat -safe 0 -i "$TEMP_FILELIST" -c copy "$OUTPUT_FILE" -y

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Successfully merged all clips into: $OUTPUT_FILE"
    
    # Get file size
    if [ -f "$OUTPUT_FILE" ]; then
        file_size=$(du -h "$OUTPUT_FILE" | cut -f1)
        echo "Merged video size: $file_size"
    fi
else
    echo ""
    echo "✗ Failed to merge clips"
    exit 1
fi

# Clean up temporary file
rm -f "$TEMP_FILELIST"

echo ""
echo "Merge complete!" 