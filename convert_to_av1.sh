#!/bin/bash

# Script to convert all H.264 videos to AV1 format
# Input: bright_light_episodes_processed directory
# Output: bright_light_episodes_av1 directory

INPUT_DIR="/home/niguo/Documents/experiments/output/bright_light_episodes_processed"
OUTPUT_DIR="/home/niguo/Documents/experiments/output/bright_light_episodes_av1"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Process each episode
for episode in "$INPUT_DIR"/episode_*.mp4; do
    if [ -f "$episode" ]; then
        filename=$(basename "$episode")
        output_file="$OUTPUT_DIR/$filename"
        
        echo "Converting $filename to AV1..."
        
        # Use FFmpeg to convert to AV1:
        # -c:v libaom-av1: Use AV1 codec
        # -crf 30: Good quality setting for AV1 (lower = better quality)
        # -preset 6: Medium speed preset (0-8, higher = faster but lower quality)
        # -cpu-used 4: CPU usage setting for encoding speed
        # -row-mt 1: Enable row-based multithreading
        # -tile-columns 2: Tile columns for parallel processing
        # -tile-rows 1: Tile rows for parallel processing
        ffmpeg -i "$episode" \
               -c:v libaom-av1 \
               -crf 30 \
               -preset 6 \
               -cpu-used 4 \
               -row-mt 1 \
               -tile-columns 2 \
               -tile-rows 1 \
               -y "$output_file"
        
        echo "Completed: $filename -> AV1"
    fi
done

echo "All episodes converted to AV1!"
echo "Original files: $INPUT_DIR"
echo "AV1 files: $OUTPUT_DIR" 