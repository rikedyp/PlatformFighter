# shot.gd
extends Area2D

const speed = 300
var enemies = {}
var velocity = Vector2()
var dir = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	connect("body_entered", self, "_on_body_entered")
	if dir == 0:
		velocity.x = -speed
	else:
		velocity.x = speed

func _on_body_entered(body):
	if int(body.name) in enemies:
		body.get_killed()

func _process(delta):
	position += delta*velocity
