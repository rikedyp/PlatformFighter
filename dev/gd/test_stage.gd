# test_stage.gd
extends Node2D

export (float) var zoom_factor = 0.5
var max_rounds

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$countdown/timer.connect("timeout", self, "_on_countdown_finished")
	$countdown/timer.wait_time = 1.5
	$countdown/timer.one_shot = true
	$countdown/timer.start()
	# Connect on screen controls
	$on_screen_controls/button.connect("toggled", self, "_toggle_on_screen_controls")
	$on_screen_controls/control_buttons/right.connect("button_down", self, "_on_screen_right")
	$on_screen_controls/control_buttons/right.connect("button_up", self, "_on_release_screen_right")
	$on_screen_controls/control_buttons/left.connect("button_down", self, "_on_screen_left")
	$on_screen_controls/control_buttons/left.connect("button_up", self, "_on_release_screen_left")
	$on_screen_controls/control_buttons/jump.connect("button_down", self, "_on_screen_jump")
	$on_screen_controls/control_buttons/jump.connect("button_up", self, "_on_release_screen_jump")
	$on_screen_controls/control_buttons/attack.connect("button_down", self, "_on_screen_attack")
	$on_screen_controls/control_buttons/attack.connect("button_up", self, "_on_release_screen_attack")

func _toggle_on_screen_controls(pressed):
	if pressed:
		$on_screen_controls/control_buttons.show()
	else:
		$on_screen_controls/control_buttons.hide()

func _on_screen_right():
	Input.action_press("move_right")
func _on_release_screen_right():
	Input.action_release("move_right")

func _on_screen_left():
	Input.action_press("move_left")
func _on_release_screen_left():
	Input.action_release("move_left")

func _on_screen_jump():
	Input.action_press("jump")
func _on_release_screen_jump():
	Input.action_release("jump")

func _on_screen_attack():
	Input.action_press("attack")
func _on_release_screen_attack():
	Input.action_release("attack")

func _on_countdown_finished():
	$countdown/label.text = "FIGHT"
	if gamestate.match_start:
		$countdown.hide()
		$countdown/timer.stop()
	for player in $players.get_children():
		player.active = true
		gamestate.match_start = true
	$countdown/timer.wait_time = 0.2
	$countdown/timer.start()

func _process(delta):
	if Input.is_action_pressed("zoom_in"):
		print("zoom")
		$camera.zoom += zoom_factor*Vector2(1,1)
	if Input.is_action_pressed("zoom_out"):
		$camera.zoom -= zoom_factor*Vector2(1,1)

func update_lives():
	for player in $players.get_children():
		var node_name = "lives/" + player.name + "/life_label"
		print(node_name)
		get_node(node_name).text = str(player.lives)

func _input(event):
	if event.get_class() == "InputEventMouseButton":
		if event.button_index == BUTTON_WHEEL_UP:
			$camera.zoom -= zoom_factor*Vector2(1,1)
		if event.button_index == BUTTON_WHEEL_DOWN:
			$camera.zoom += zoom_factor*Vector2(1,1)