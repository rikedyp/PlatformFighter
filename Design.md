# Platform Fighter (Working Title)
Open Source TowerFall / Smash Bros esque fighting game
Made with Godot 3

Design notes and future ideas

CONTENTS  
[Overview](#overview)  
[Gameplay](#gameplay)  
[Godot project structure](#godot-project-structure)  
[Development](#development)
[Multiplayer methods](#multiplayer-methods)
[Future ideas](#future-ideas)  
[Fighters](#fighters)
[Stages](#stages)
  
### Overview
- Open Source Towerfall / Smash Bros clone

### Gameplay
- User stories
	- 1 Title screen
		- Solo
		- Multiplayer
	- 2 Multiplayer lobby
		- Text Input host IP address
- Simple gravity
- Player stabs or shoots
	- Jump on head - kill
	- Shoot body - kill
	- Stab body - kill
- Respawn
	- Player assigned spawn point on match start
	- [Optional] players respawn at random spawn points

### Multiplayer methods
- Based on the multiplayer bomber in Godot demo projects

### Godot project structure
- Design.md
	This document
- LICENSE
	Licensing information
- README.md
	Github page readme
- dev
	Development folder
	- project.godot
	- icon.png
	- assets
		- fighters
		- baddies [not currently used]
		- fonts
		- stages
		- ui
	- gd
		All .gd scripts
	- bin
		Development binaries by date

- release
	Release binaries by version

### Development
Each version is described by its github project board  
ToDo | In Progress | Done | Testing  

All TODOs, including inside .gd file comments, must be completed before a release is considered ready  
If a TODO isn't essential for that release, put it into Future ideas section until development of the next version commences.  

### Future ideas
- Quick fall maybe
- Game option choosing process
	- Majority rule
	- Dictatorship
	- Vote then random like MK8
	- Random selection
- Teams
	- Toggle friendly fire
- Dodge 
	- Super dodge
- Shoot head - hat off
	
### Fighters
- Ninja
	- Can walk on air if they crane jump on ledge
	- Stab attack
	- Head jump attack
- Pirate
	- Shoot attack (lead shot)
	- Head jump attack

### Stages
- Test stage
	- TODO: Shakey 'READY', 'FIGHT' graphics