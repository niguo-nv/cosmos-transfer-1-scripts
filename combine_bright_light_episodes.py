#!/usr/bin/env python3
import os
import subprocess
import re
import shutil
from pathlib import Path

def get_all_episodes():
    """Get all episode numbers from laptop clips directory"""
    clips_dir = Path("/home/niguo/Documents/experiments/output/observation.table_cam.h264/sim_clips")
    episodes = set()
    
    # Pattern to match episode_XXXXXX_clip_YYYY.mp4
    pattern = re.compile(r'episode_(\d+)_clip_(\d+)\.mp4')
    
    for filename in clips_dir.iterdir():
        if filename.is_file() and filename.suffix == '.mp4':
            match = pattern.match(filename.name)
            if match:
                episode_num = int(match.group(1))
                episodes.add(episode_num)
    
    return sorted(list(episodes))

def get_episode_clip_count(episode_num):
    """Get the number of clips for a specific episode from laptop clips directory"""
    clips_dir = Path("/home/niguo/Documents/experiments/output/observation.table_cam.h264/sim_clips")
    
    # Pattern to match episode_XXXXXX_clip_YYYY.mp4
    pattern = re.compile(f'episode_{episode_num:06d}_clip_(\d+)\.mp4')
    
    clip_numbers = []
    for filename in clips_dir.iterdir():
        if filename.is_file() and filename.suffix == '.mp4':
            match = pattern.match(filename.name)
            if match:
                clip_num = int(match.group(1))
                clip_numbers.append(clip_num)
    
    return len(clip_numbers)

def combine_bright_light_videos_to_episode(episode_num, start_video_idx, num_clips):
    """Combine bright_light videos into a single episode"""
    bright_light_dir = Path("/home/niguo/Documents/experiments/vids/sim_dark")
    output_dir = Path("/home/niguo/Documents/experiments/output/sim_dark_episodes")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Create a temporary file list for ffmpeg
    temp_list_file = f"temp_episode_{episode_num:06d}_list.txt"
    
    try:
        with open(temp_list_file, 'w') as f:
            for i in range(num_clips):
                video_idx = start_video_idx + i
                video_dir = bright_light_dir / f"video_{video_idx}"
                output_file = video_dir / "output.mp4"
                
                if output_file.exists():
                    f.write(f"file '{output_file}'\n")
                else:
                    print(f"Warning: {output_file} not found")
        
        # Output filename following the episode naming convention
        output_filename = f"episode_{episode_num:06d}.mp4"
        output_path = output_dir / output_filename
        
        # Use ffmpeg to concatenate all clips
        cmd = [
            'ffmpeg', '-f', 'concat', '-safe', '0',
            '-i', temp_list_file,
            '-c', 'copy',  # Copy without re-encoding for speed
            str(output_path),
            '-y'  # Overwrite if exists
        ]
        
        print(f"Combining episode {episode_num} (videos {start_video_idx} to {start_video_idx + num_clips - 1})...")
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            print(f"✓ Successfully created {output_path}")
            return output_path
        else:
            print(f"✗ Error combining episode {episode_num}: {result.stderr}")
            return None
            
    except Exception as e:
        print(f"✗ Error processing episode {episode_num}: {e}")
        return None
    finally:
        # Clean up temporary file
        if os.path.exists(temp_list_file):
            os.remove(temp_list_file)

def main():
    # Get all episodes from laptop clips directory
    all_episodes = get_all_episodes()
    print(f"Found {len(all_episodes)} episodes to process")
    
    # Track the current video index (starts at 0)
    current_video_idx = 0
    
    successful_episodes = []
    failed_episodes = []
    
    for episode_num in all_episodes:
        # Get the number of clips for this episode
        num_clips = get_episode_clip_count(episode_num)
        print(f"\nEpisode {episode_num} has {num_clips} clips")
        
        if num_clips > 0:
            # Combine the corresponding videos into this episode
            output_path = combine_bright_light_videos_to_episode(episode_num, current_video_idx, num_clips)
            
            if output_path:
                successful_episodes.append(episode_num)
                print(f"✓ Successfully created episode {episode_num}")
            else:
                failed_episodes.append(episode_num)
                print(f"✗ Failed to create episode {episode_num}")
            
            # Move to the next set of videos
            current_video_idx += num_clips
        else:
            print(f"Skipping episode {episode_num} - no clips found")
    
    # Summary
    print(f"\n=== SUMMARY ===")
    print(f"Successfully created {len(successful_episodes)} episodes: {successful_episodes}")
    if failed_episodes:
        print(f"Failed to create {len(failed_episodes)} episodes: {failed_episodes}")
    print(f"Total videos processed: {current_video_idx}")

if __name__ == "__main__":
    main() 