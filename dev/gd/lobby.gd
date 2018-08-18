extends Control

var player_scene
var player_animation

func _ready():
	# Called every time the node is added to the scene.
	# Connect buttons
	for button in $player_select/player_buttons.get_children():
		print(button.name)
		var func_name = "_on_" + button.name + "_pressed"
		var toggle_name = "_on_" + button.name + "_toggled"
		button.connect("pressed", self, func_name)
		button.connect("toggled", self, toggle_name)
	$player_select/ready.connect("pressed", self, "_on_ready_pressed")
	$players/start.connect("pressed", self, "_on_start_pressed")
	# Connect gamestate functions
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")

#func ip_in_use():
#	# TODO check this does something
#	get_node("connect").show()
#	get_node("players").hide()
#	get_node("vehicle_select").hide()
#	get_node("connect/error_label").text = "IP address in use"

func _on_host_pressed():
	# TODO set # laps
	if get_node("connect/name").text == "":
		get_node("connect/error_label").text = "Invalid name!"
		return
	$connect.hide()
	# Only host accesses some settings
	# TODO: Consider voting process (majority rules or MKart style)
	$player_select.show()
	# Only host can set game options e.g. # rounds
	get_node("connect/error_label").text = ""
	var player_name = get_node("connect/name").text
	gamestate.host_game(player_name)
	refresh_lobby()

func _on_join_pressed():
	if get_node("connect/name").text == "":
		get_node("connect/error_label").text = "Invalid name!"
		return
	var ip = get_node("connect/ip").text
	if not ip.is_valid_ip_address():
		get_node("connect/error_label").text = "Invalid IPv4 address!"
		return
	get_node("connect/error_label").text=""
	get_node("connect/host").disabled = true
	get_node("connect/join").disabled = true
	var player_name = get_node("connect/name").text
	gamestate.join_game(ip, player_name)
	# refresh_lobby() gets called by the player_list_changed signal

func _on_connection_success():
	get_node("connect").hide()
	get_node("player_select").show()

func _on_connection_failed():
	get_node("connect/host").disabled = false
	get_node("connect/join").disabled = false
	get_node("connect/error_label").set_text("Connection failed.")

func _on_game_ended():
	show()
	get_node("connect").show()
	get_node("players").hide()
	#get_node("vehicle_select").hide()
	get_node("connect/host").disabled = false
	get_node("connect/join").disabled

func _on_game_error(errtxt):
	get_node("error").dialog_text = errtxt
	get_node("error").popup_centered_minsize()

func refresh_lobby(): # sync func?
	var players = gamestate.players
	var players_choosing = gamestate.get_players_ready()
	get_node("players/list").clear()
	if not gamestate.my_player_info["ready"]:
		get_node("players/list").add_item(gamestate.my_player_info["name"] + " (You) [Choosing vehicle...]")
	else:
		get_node("players/list").add_item(gamestate.my_player_info["name"] + " (You) [Ready.]")
	if not players.empty():
		for p_id in players:
			var p = players[p_id]["name"]
			if not players[p_id]["ready"]:
				if p_id == get_tree().get_network_unique_id():
					p += " (You) [Choosing...]"
				else:
					p += " [Choosing...]"
			else:
				if p_id == get_tree().get_network_unique_id():
					p += " (You) [Ready.]"
				else:
					p += " [Ready.]"
			get_node("players/list").add_item(p)

	get_node("players/start").disabled = not get_tree().is_network_server()

func _on_start_pressed():
	gamestate.rpc("set_max_rounds",int($settings/list/rounds.text))
	gamestate.begin_game()

func free_child_nodes(node):
	# TODO is this still used?
	for child in node.get_children():
		child.queue_free()

func _on_player_button_pressed():
	pass

func _on_ninja_pressed():
	gamestate.my_player_info["scene_file"] = "res://assets/fighters/ninja/ninja.tscn"

func _on_pirate_pressed():
	gamestate.my_player_info["scene_file"] = "res//assets/fighter/pirate/pirate.tscn"

func _on_ninja_toggled(pressed):
	if pressed:
		$player_select/ready.disabled = false
	else:
		$player_select/ready.disabled = true

func _on_pirate_toggled(pressed):
	if pressed:
		$player_select/ready.disabled = false
	else:
		$player_select/ready.disabled = true

func _on_ready_pressed():
	gamestate.ready_player()
	#gamestate.my_player_info["ready"] = true
	$player_select.hide()
	$players.show()
	if get_tree().get_network_unique_id() == 1:
		$settings.show()
	#refresh_lobby()
	
