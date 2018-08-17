extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (float) var zoom_factor = 0.5
var max_rounds

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#$countdown/label
	$countdown/timer.connect("timeout", self, "_on_countdown_finished")
	$countdown/timer.wait_time = 1.5
	$countdown/timer.one_shot = true
	$countdown/timer.start()
	pass

func _on_countdown_finished():
	$countdown/label.text = "FIGHT"
	if gamestate.my_player.active:
		$countdown.hide()
	for player in $players.get_children():
		player.active = true
	$countdown/timer.wait_time = 0.5
	$countdown/timer.start()

func _process(delta):
	if Input.is_action_pressed("zoom_in"):
		print("zoom")
		$camera.zoom += zoom_factor*Vector2(1,1)
	if Input.is_action_pressed("zoom_out"):
		$camera.zoom -= zoom_factor*Vector2(1,1)

func _input(event):
	if event.get_class() == "InputEventMouseButton":
		if event.button_index == BUTTON_WHEEL_UP:
			$camera.zoom -= zoom_factor*Vector2(1,1)
		if event.button_index == BUTTON_WHEEL_DOWN:
			$camera.zoom += zoom_factor*Vector2(1,1)