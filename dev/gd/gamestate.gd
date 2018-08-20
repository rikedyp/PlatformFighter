# gamestate.gd
extends Node

# Default game port
const default_port = 14204 # 8910

# Max number of players
const max_peers = 2

# Match # rounds
var max_rounds = 3

var match_start = false

# Details for my player
var my_player
var my_player_info = {
	"name": "",
	"scene_file": "",
	"ready": false,
	"lives": 1 # Current number of lives 
	} 
var my_towers = []
# Details for remote players 
var players = {} # dict by id:profile format
# where profile is a dict "property": value
# {id: {"name": "player_name", "scene_file" = "player_scene_path"}} etc.
# name, scene, ready, lives

# Signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what) # TODO change variable name

# Callback from SceneTree
func _player_connected(id):
	# This is not used in this demo, because _connected_ok is called for clients
	# on success and will do the job.
	pass

# Callback from SceneTree
func _player_disconnected(id):
	if get_tree().is_network_server():
		if has_node("/root/test_stage"): # Game is in progress
			emit_signal("game_error", "Player " + players[id]["name"] + " disconnected")
			end_game()
		else: # Game is not in progress
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)

# Callback from SceneTree, only for clients (not server)
func _connected_ok():
	# Registration of a client beings here, tell everyone that we are here
	rpc("register_player", get_tree().get_network_unique_id(), my_player_info)
	emit_signal("connection_succeeded")

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# --- Lobby management functions --- #

remote func register_player(id, new_player_dict):
	# TODO set # laps
	if get_tree().is_network_server():
		# If we are the server, let everyone know about the new player
		rpc_id(id, "register_player", 1, my_player_info) # Send myself to newly connected player
		for p_id in players: # Then, for each remote player
			rpc_id(id, "register_player", p_id, players[p_id]) # Send existing player to new player
			rpc_id(p_id, "register_player", id, new_player_dict) # Send new player to existing player
	players[id] = new_player_dict
	emit_signal("player_list_changed")

remote func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

remote func register_fighter(id, new_player_scene):
	if new_player_scene == "":
		players[id]["ready"] = false
	else:
		players[id]["ready"] = true
	players[id]["scene_file"] = new_player_scene
	emit_signal("player_list_changed")

remote func pre_start_game(spawn_points, max_rounds):
	# Change scene
	var world = load("res://assets/stages/test_stage.tscn").instance()
	world.max_rounds = max_rounds
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("lobby").hide()
	for p_id in spawn_points:
		var spawn_pos = world.get_node("spawn_points/" + str(spawn_points[p_id])).position
		var player
		var life_counter = VBoxContainer.new()
		var name_label = Label.new()
		name_label.set_name("name_label")
		var life_label = Label.new()
		life_label.set_name("life_label")
		life_label.text = str(max_rounds)
		life_counter.add_child(name_label)
		life_counter.add_child(life_label)
		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set up player here
			my_player = load(my_player_info["scene_file"]).instance()
			player = my_player
			player.set_name(str(p_id)) # set unique id as node name
			life_counter.set_name(str(p_id))
			name_label.text = my_player_info["name"]
			player.position = spawn_pos
			player.set_player_name(my_player_info["name"])
			player.lives = max_rounds
		else:
			# Otherwise set up player from peer
			player = load(players[p_id]["scene_file"]).instance()
			player.set_name(str(p_id))
			life_counter.set_name(str(p_id))
			name_label.text = players[p_id]["name"]
			player.position = spawn_pos
			player.set_player_name(players[p_id]["name"])
			player.lives = max_rounds
		player.set_network_master(p_id) # set unique id as master
		world.get_node("players").add_child(player)
		# Add life counters for each player
		world.get_node("lives").add_child(life_counter)
	if not get_tree().is_network_server():
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!

remote func ready_to_start(id):
	assert(get_tree().is_network_server())
	for player in players:
		rpc_id(int(player), "post_start_game")
	post_start_game()

func host_game(new_player_name):
	my_player_info["name"] = new_player_name
	var host = NetworkedMultiplayerENet.new()
	#host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(default_port, max_peers) # max: 1 peer, since it's a 2 players game
	if (err!=OK):
		#is another server running?
		emit_signal("game_error", "IP address in use or invalid.")
		end_game()
	get_tree().set_network_peer(host)

func join_game(ip, new_player_name):
	my_player_info["name"] = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, default_port)
	get_tree().set_network_peer(host)

func begin_game():
	if not my_player_info["ready"]:
		if gamestate.my_player == null:
			print("You haven't chosen yet")
			emit_signal("game_error", "You haven't chosen yet")
			return
		var printstring = gamestate.my_player["name"] + " yet to choose..."
		print(printstring)
		return
	else:
		for p in players:
			if not players[p]["ready"]:
				var printstring = players[p]["name"] + " yet to choose..."
				emit_signal("game_error", printstring)
				print(printstring)
				return
	assert(get_tree().is_network_server())
	
	# Create a dictionary with peer id and respective spawn points, vehicle scenes and vehicle animations, could be improved by randomizing spawn points
	var spawn_points = {}
	spawn_points[1] = 1 # Server in spawn point 1
	var spawn_point_idx = 2
	# Assign spawn points
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	
	# Call to pre-start game with the spawn points, max_rounds (lives)
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points, max_rounds)
	pre_start_game(spawn_points, max_rounds)

func see_children(node):
	print("-----")
	for child in node.get_children():
		print(child.get_name())
		see_children(child)

func end_game():
	if has_node("/root/test_stage"): # Game is in progress
		# End it
		get_node("/root/test_stage").queue_free()
	get_tree().change_scene("res://assets/ui/lobby.tscn")
	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func ready_player():
	my_player_info["ready"] = true
	rpc("register_fighter", get_tree().get_network_unique_id(), my_player_info["scene_file"])
	
func still_choosing():
	my_player_info["ready"] = false
	emit_signal("player_list_changed")

sync func set_max_rounds(rounds):
	max_rounds = rounds

remote func update_score(id, score):
	players[id]["score"] = score

sync func respawn_player(id):
	get_node("/root/test_stage").update_lives()
	var node_name = "/root/test_stage/players/" + id
	var respawn_player = get_node(node_name)
	respawn_player.set_global_position(get_node("/root/test_stage/spawn_points/0").get_global_position())
