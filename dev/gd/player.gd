# player.gd
extends KinematicBody2D

# These variables determine handling of fighter
export (int) var jump_power = 1000
export (int) var move_speed = 400
export (int) var gravity = 50
export (bool) var active = false
var max_lives
var spawn_pos
var anim
var dir = 1
var jumping = false
var jump_flag = 2
var jump_time = 0.0
var on_floor = false
var attacking = false
var attack_time = 0.0
var velocity = Vector2()

# This updates the position for other clients
slave func set_pos_and_motion(p_pos, p_vel, p_dir, attack_state, jump_state, animation, play):
	position = p_pos
	velocity = p_vel
	dir = p_dir
	if dir == 1:
		anim.flip_h = false
	else:
		anim.flip_h = true
	anim.set_animation(animation)
	if play:
		anim.play()
	else:
		anim.stop()
	attacking = attack_state
	jumping = jump_state

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$head.connect("body_entered", self, "_on_head_entered")
	anim = $animated_sprite
	anim.connect("animation_finished", self, "_on_animation_finished")
	set_physics_process(true)
	$label.text = get_name()
	gamestate.players["ninja"] = [1234, "ninja"]

func set_player_name(new_name):
	$label.set_text(new_name)

func _process(delta):
	pass

func _physics_process(delta):
	pass
	if active and int(get_name()) == get_tree().get_network_unique_id():
		handle_input(delta)
	handle_collisions()
	rpc("set_pos_and_motion", position, velocity, dir, attacking, jumping, anim.get_animation(), anim.playing)
	if Input.is_action_just_pressed("dodge"):
		get_killed()
	if Input.is_action_just_pressed("ui_select"):
		# TODO: Check synchronisity of this type of input function
		print("I'm ALIVE!")

func handle_input(delta):
	# --- GENERAL PLAYER INPUT AND MOTION --- #
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_just_pressed("jump")
	var attack = Input.is_action_just_pressed("attack")
	var acceleration = Vector2()
	if jump and jump_flag > 0 and not attacking:
		print("jump")
		velocity.y = -jump_power
		jumping = true
		on_floor = false
		jump_flag -= 1
		jump_time = 0.0
		anim.set_animation("jump")
		anim.set_frame(0)
	if jumping and not attacking:
		jump_time += delta
		anim.set_animation("jump")
	if move_left and not attacking:
		dir = 0
		velocity.x = -move_speed
		#print("move_left")
		if not jumping:
			anim.set_animation("run")
		anim.flip_h = true
		$hit_box.position.x = 20
		$head.position.x = 30
	elif move_right and not attacking:
		dir = 1
		velocity.x = move_speed
		if not jumping:
			anim.set_animation("run")
			anim.play()
		anim.flip_h = false
		$hit_box.position.x = -15
		$head.position.x = 0
	elif not jumping and not attacking:
		anim.set_animation("idle")
		anim.play()
		velocity.x = 0
	elif jumping:
		velocity.x = 0
	_custom_action(delta, attack)
	if attacking:
		velocity.y = 0
	else:
		acceleration.y += gravity
	velocity += acceleration

func _custom_action(delta, attack):
	# --- FIGHTER SPECIFIC ACTION --- #
	if attack:
		attack_time = 0.0
		anim.set_animation("attack")
		anim.play()
		attacking = true
	if attacking:
		attack_time += delta
		#print("attacking")
		if attack_time > 0.3 and attack_time < 0.4:
			if dir == 1:
				velocity.x = move_speed
			else:
				velocity.x = -move_speed

func handle_collisions():
	var normal = move_and_slide(velocity) # col = collision
	if get_slide_count() != 0 :
		for i in range (0,get_slide_count()) :
			var col = get_slide_collision(i).collider
			if col.name == "floor":
				jump_flag = 2
				jumping = false
				on_floor = true
				velocity.y = 0
			if int(col.name) in gamestate.players:# or col.name == "ninja":
				print("got em")
				jump_flag = 1
				jumping = true
				on_floor = false
				if normal == Vector2(0, 0) and not attacking:
					velocity.y -= jump_power
				print("collision")
				print(col.name)
				if jumping:
					col.get_killed()

func _on_animation_finished():
	if anim.animation == "attack":
		# print("end attack")
		anim.stop()
		attacking = false

func _on_head_entered(body):
	#print("head enter")
	#print(body.name)
	#print(body.jumping)
	#print("players")
	#print(gamestate.players)
	if body.name in gamestate.players and body.name != get_name():# or body.name == "1":
		print("HEAD ENTER IN HERE")
		print(body.name)
		print(body.attacking)
		print(body.jumping)

func get_killed():
	gamestate.rpc("respawn_player", name)




