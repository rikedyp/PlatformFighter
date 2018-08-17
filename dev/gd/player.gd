extends KinematicBody2D

# These variables determine handling of fighter
export (int) var jump_power = 1000
export (int) var move_speed = 400
export (int) var gravity = 50
export (bool) var active = false
var dir = 1
var jumping = false
var jump_flag = 2
var jump_time = 0.0
var on_floor = false
var attacking = false
var attack_time = 0.0
var velocity = Vector2()

#This updates the position on the other end
slave func set_pos_and_motion(p_pos, p_vel_iso, p_dir):
	pass

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$head.connect("body_entered", self, "_on_head_entered")
	$body.connect("body_entered", self, "_on_body_entered")
	$animated_sprite.connect("animation_finished", self, "_on_animation_finished")
	set_physics_process(true)
	pass

func _process(delta):
	pass

func _physics_process(delta):
	pass
	if active:
		handle_input(delta)
	handle_collisions()

func handle_input(delta):
	var move_left = Input.is_action_pressed("move_left")
	var move_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_just_pressed("jump")
	var attack = Input.is_action_just_pressed("attack")
	var acceleration = Vector2()
	if jump and jump_flag > 0:
		print("jump")
		velocity.y = -jump_power
		jumping = true
		on_floor = false
		jump_flag -= 1
		jump_time = 0.0
		$animated_sprite.set_animation("jump")
		$animated_sprite.set_frame(0)
	if jumping:
		jump_time += delta
		$animated_sprite.set_animation("jump")
	if move_left and not attacking:
		dir = 0
		velocity.x = -move_speed
		#print("move_left")
		if not jumping:
			$animated_sprite.set_animation("run")
		$animated_sprite.flip_h = true
	elif move_right and not attacking:
		dir = 1
		velocity.x = move_speed
		if not jumping:
			$animated_sprite.set_animation("run")
			$animated_sprite.play()
		$animated_sprite.flip_h = false
	elif not jumping and not attacking:
		$animated_sprite.set_animation("idle")
		$animated_sprite.play()
		velocity.x = 0
	elif jumping:
		velocity.x = 0
	if attack:
		attack_time = 0.0
		$animated_sprite.set_animation("attack")
		$animated_sprite.play()
		attacking = true
	if attacking:
		attack_time += delta
		#print("attacking")
		if attack_time > 0.3 and attack_time < 0.4:
			#print(attack_time)
			if dir == 1:
				velocity.x = move_speed
			else:
				velocity.x = -move_speed
	acceleration.y += gravity#*jump_time
	#print(velocity)
	#if not on_floor:
	velocity += acceleration#*jump_time
	# --- FOR NINJA ONLY --- #
#	if on_floor and not jumping:
#		velocity.y = 0
	# --- TYPICAL FIGHTER --- #
	
	#$label.text = str(acceleration) + ", " + str(velocity) + ", " + str(jumping)

func handle_collisions():
	var normal = move_and_slide(velocity) # col = collision
	if get_slide_count() != 0 :
		for i in range (0,get_slide_count()) :
			$label.text = str(get_slide_collision(i).collider.name)
			if get_slide_collision(i).collider.name == "floor":
				#print("on floor")
				jump_flag = 2
				jumping = false
				on_floor = true
				velocity.y = 0
			if get_slide_collision(i).collider.name == "player_2":
				#print(normal)
				#print("got em")
				jump_flag = 1
				jumping = true
				on_floor = false
				if normal == Vector2(0, 0):
					velocity.y -= jump_power
#			if get_slide_collision(i).collider.name == "player":
#				get_killed()
#	if col:
#		#print(col.collider.name)
#		if col.collider.name == "floor" and velocity.y > 0:
#			velocity.y = 0
#		if col.collider.name == "player" and name != "player":
#			print("player player")
#			get_killed()
#		if col.collider.name == "player_2" and name != "player_2":
#			print("got player_2")
#		jump_flag=2
#		jumping = false

func _on_animation_finished():
	if $animated_sprite.animation == "attack":
		$animated_sprite.stop()
		attacking = false

func _on_head_entered(body):
	#print(body.get_name())
	if body.name == "player" and name != "player":
		if body.attacking or body.jumping:
			get_killed()

func _on_body_entered(body):
	if body.name == "player_2" and name != "player_2":
		velocity.y -= jump_power
	print(body.get_name())

func get_killed():
	queue_free()


