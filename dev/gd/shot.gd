# shot.gd
extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const speed = 300
var enemies = {}
var velocity = Vector2()
var dir = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	connect("body_entered", self, "_on_body_entered")
	#print(get_parent().name)
	if dir == 0:
		velocity.x = -speed
	else:
		velocity.x = speed
	pass

func _on_body_entered(body):
	#print("SHOOT")
	#print(body.name)
	#print(enemies)
	if int(body.name) in enemies:
		body.get_killed()

func _process(delta):
	position += delta*velocity
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
