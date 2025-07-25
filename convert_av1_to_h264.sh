#!/bin/bash

# Converts LeRobot videos from AV1 encoding to h264 encoding

# Function to convert videos in a directory
convert_videos() {
    local input_dir="$1"
    local output_dir="$2"
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"
    
    for file in "$input_dir"/*.mp4; do
        # Check if the file exists and is a regular file
        if [ -f "$file" ]; then
            # Extract filename without extension
            filename=$(basename -- "$file")
            filename_no_ext="${filename%.*}"

            # Construct output filename
            output_file="$output_dir/${filename_no_ext}.mp4"

            echo "Converting '$file' to '$output_file'..."

            # FFmpeg command for conversion
            ffmpeg -i "$file" -c:v libx264 -preset medium -crf 23 -c:a aac -b:a 128k "$output_file"
            
            if [ $? -eq 0 ]; then
                echo "Successfully converted '$file'."
            else
                echo "Error converting '$file'."
            fi
        fi
    done
}

# # Convert laptop videos
# echo "Processing laptop videos..."
# convert_videos "./observations/observation.images.laptop" "./output/observation.images.laptop.h264"

# # Convert wrist videos
# echo "Processing wrist videos..."
# convert_videos "./observations/observation.images.wrist.sim" "./output/observation.images.wrist.h264.sim"

# Convert table_cam videos
echo "Processing table_cam videos..."
convert_videos "./observations/observation.images.wrist.sim" "./output/observation.images.wrist.h264.sim"

echo "Batch conversion complete."