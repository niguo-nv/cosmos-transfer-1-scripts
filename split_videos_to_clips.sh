#!/bin/bash

# Script to split videos into 4-second clips
# Usage: ./split_videos_to_clips.sh

# Source directory containing the videos
SOURCE_DIR="output/observation.table_cam.h264"

# Output directory for clips
OUTPUT_DIR="output/observation.table_cam.h264/clips"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install ffmpeg first."
    exit 1
fi

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

echo "Starting video splitting process..."
echo "Source directory: $SOURCE_DIR"
echo "Output directory: $OUTPUT_DIR"
echo ""

# Counter for total processed videos
total_videos=0
total_clips=0

# Process each video file in the source directory
for video_file in "$SOURCE_DIR"/episode_*.mp4; do
    # Check if file exists (in case no files match the pattern)
    if [ ! -f "$video_file" ]; then
        echo "No video files found in $SOURCE_DIR"
        exit 1
    fi
    
    # Extract episode number from filename
    filename=$(basename "$video_file")
    episode_num=$(echo "$filename" | sed 's/episode_\([0-9]*\)\.mp4/\1/')
    
    echo "Processing: $filename"
    
    # Get video duration using ffprobe
    duration=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$video_file")
    
    # Calculate number of clips needed (4 seconds each)
    clip_duration=4
    num_clips=$(echo "scale=0; ($duration + $clip_duration - 1) / $clip_duration" | bc)
    
    echo "  Duration: ${duration}s"
    echo "  Creating $num_clips clips..."
    
    # Split video into clips
    for ((i=0; i<num_clips; i++)); do
        start_time=$(echo "$i * $clip_duration" | bc)
        
        # Format episode number with leading zeros (avoid octal interpretation)
        episode_formatted=$(echo "$episode_num" | awk '{printf "%06d", $1}')
        clip_formatted=$(echo "$i" | awk '{printf "%03d", $1}')
        
        output_filename="episode_${episode_formatted}_clip_${clip_formatted}.mp4"
        output_path="$OUTPUT_DIR/$output_filename"
        
        echo "    Creating clip $((i+1))/$num_clips: $output_filename"
        
        # Use ffmpeg to create the clip
        ffmpeg -i "$video_file" -ss "$start_time" -t "$clip_duration" -c:v libx264 -c:a aac -strict experimental "$output_path" -y -loglevel error
        
        if [ $? -eq 0 ]; then
            echo "      ✓ Successfully created $output_filename"
            ((total_clips++))
        else
            echo "      ✗ Failed to create $output_filename"
        fi
    done
    
    ((total_videos++))
    echo ""
done

echo "Processing complete!"
echo "Total videos processed: $total_videos"
echo "Total clips created: $total_clips"
echo "Clips saved in: $OUTPUT_DIR" 