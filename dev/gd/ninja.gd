# ninja.gd
extends "res://gd/player.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
#var attacking = false
var force_fall = false # flag for ninja slow-fall behaviour

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _on_animation_finished():
	if anim.animation == "attack":
		anim.stop()
		attacking = false
		$attack_box.queue_free()

func create_attack_box():
	var attack_box = Area2D.new()
	var hit_box = CollisionShape2D.new()
	var hit_shape = CircleShape2D.new()
	hit_shape.radius = 5
	hit_box.shape = hit_shape
	attack_box.set_name("attack_box")
	attack_box.add_child(hit_box)
	attack_box.connect("body_entered", self, "_on_attack_box_entered")
	add_child(attack_box)
	if dir == 1:
		attack_box.position.x += 20
	else:
		attack_box.position.x -= 20

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func _custom_action(delta, attack):
	# --- FIGHTER SPECIFIC ACTION --- #
	if Input.is_action_pressed("ui_down"):
		force_fall = true
	else:
		force_fall = false
	if attack:
		create_attack_box()
		attack_time = 0.0
		anim.set_animation("attack")
		anim.play()
		attacking = true
	if attacking:
		attack_time += delta
		#print("attacking")
		if attack_time > 0.3 and attack_time < 0.4:
			# Create attack box and connect to _on_attack_box_enter function
			#print(attack_time)
			if dir == 1:
				velocity.x = move_speed
			else:
				velocity.x = -move_speed
	# Ninja slow-fall
	if on_floor and not jumping and not force_fall:
		velocity.y = 0

