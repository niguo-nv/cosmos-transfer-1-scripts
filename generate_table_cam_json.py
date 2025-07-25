#!/usr/bin/env python3

# python3 generate_table_cam_json.py > commands.txt

# Generates batch control input .json for multiple video inputs

import json

# The prompt from the laptop episodes
prompt = "The video is set in a modern workspace, featuring a light-colored wooden table as the central element. On the table, a stack of white cubes with bold black symbols is arranged in a slightly irregular tower. A robotic arm with a black gripper hovers above the cubes, poised for interaction. The background is softly blurred, suggesting a clean, professional environment. In the original scene, the lighting is neutral and even, providing clear visibility of the objects and their details. For the augmented version, the lighting shifts gently to introduce a warmer, late-afternoon feel. Soft, golden sunlight subtly filters in from the side, adding a faint warmth and delicate, elongated shadows to the table and cubes. The highlights on the cubes and robotic arm are now slightly tinged with amber, while the background acquires a mild, inviting glow. The overall effect is understated—maintaining clarity and balance while infusing the workspace with a touch of warmth and depth. The camera remains fixed, focusing on the interaction between the robotic arm and the cubes as the subtle lighting shift brings a more welcoming, natural atmosphere to the scene."

# Generate JSON entries for clips 000 to 004
for i in range(5):
    clip_num = f"{i:03d}"
    visual_input = f"/lustre/akuls/demo_vids/split_clips/clip_{clip_num}.mp4"
    
    entry = {
        "visual_input": visual_input,
        "prompt": prompt,
        "edge": {"control_weight": 0.5},
        "seg": {"control_weight": 0.5}
    }
    
    print(json.dumps(entry)) 