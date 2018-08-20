# pirate.gd
extends "res://gd/player.gd"

export (int) var gun_kickback = 500
var shooting = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _custom_action(delta, attack):
	if attack and not attacking:
		attack_time = 0.0
		anim.set_animation("attack")
		anim.play()
		attacking = true
		#jumping = false
	if attacking:
		#velocity.y = 0
		attack_time += delta
		if attack_time > 0.4 and attack_time < 0.44:
			if not shooting:
				shooting = true
				#shoot()
				rpc("shoot")
			if dir == 1:
				velocity.x = -gun_kickback
			else:
				velocity.x = gun_kickback
		elif attack_time > 0.44:
			velocity.x = 0
			shooting = false
			#attacking = false

sync func shoot():
	print("shoot")
	var shot = load("res://assets/fighters/pirate/shot.tscn").instance()
	shot.enemies = gamestate.players # who's gamestate?
	shot.dir = dir
	shot.position = get_global_position()
	get_parent().get_parent().add_child(shot)