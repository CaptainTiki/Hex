# Project Hex - Architecture Notes

## Core Principles

- Above all - ask if you need clarity - do not assume

- Godot 4.6
- 2.5D gameplay using 3D assets
- Player movement is constrained to a gameplay plane
- Scene-driven, node-first architecture
- Short focused scripts
- Inspector-driven reusable scenes
- Build only what the wow slice needs
- Feel-first prototype: prioritize movement, visuals, effects, lighting, animation, and sound
- Avoid premature procgen, metaprogression, inventory, or full-game systems
- Set up signal connections through editor rather than through code
- Do not break from good code in order to "quickly" bandaid an issue - do it right

## System Rules

- Prefer components over deep inheritance
- Prefer reusable scenes over giant scripts
- Keep scripts colocated with their scenes whenever practical
- A scene and its primary script should usually live in the same folder
- Parent nodes own references to child components
- Sibling nodes should not directly control each other
- Sibling communication should go through the parent or through signals
- Components should expose simple actions and events
- Use exported variables so behavior can be tuned in the inspector
- Avoid global managers/autoloads unless the need is obvious

## Organization Style

Use feature folders instead of separate global `scenes/` and `scripts/` folders.

## In scope:

- player movement
- jump/dash feel
- squishy player visuals
- one weapon
- one or two enemies
- one hand-built room
- modular room pieces
- glowing materials
- shader background
- particles/fog
- basic sound
