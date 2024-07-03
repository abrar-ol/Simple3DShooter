extends Node3D

# $MultiplayerSpawner: uesed because with out it
# the host contolling both client and server and both spawn in the server
# 1- add spawn path: we are instanceing the players as a child of World node
# 2- auto spawn list: add player secene ( what we want to spawn )
# 3- in the player script: server and client can only control their corresponding players 
# by set up the authority and connect it to their corresponding peer

@onready var main_menu = $CanvasLayer/MainMenu
@onready var adress_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AdressEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar

var enet_peer = ENetMultiplayerPeer.new()

const PORT = 9999
const PLAYER = preload("res://scenes/player.tscn")

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player) #  When player press join --> add player
	# (wire up a signal) peer_connected is a signal thet is going to emmit 
	# at a server every time a client connect to it
	# it connects add_player, it's gonna pass in the new peer id
	
	add_player(multiplayer.get_unique_id()) 
	
	# make sure to remove the client from the scene when quit:
	multiplayer.peer_disconnected.connect(remove_player)
	
	upnp_setup()

func _on_join_button_2_pressed():
	main_menu.hide()
	hud.show()	
	enet_peer.create_client(adress_entry.text,PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
 
func update_health_bar(health_value):
	health_bar.value = health_value

# for connecting the players in the clients
func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)

# to connect with other players:
func upnp_setup():
	var upnp = UPNP.new()  
	#discover (UPNP device = my router with upnp enabled):
	var discover_result = upnp.discover()
	assert(discover_result==UPNP.UPNP_RESULT_SUCCESS,\
	"UPNP Discover failed! Error %s" % discover_result)
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(),\
	"UPNP Invalid Gateway")
	
	#create the port mapping to automatic port forwarding
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result==UPNP.UPNP_RESULT_SUCCESS,\
	"UPNP Port mapping failed! Error %s" % map_result)
	
	# if all asserts work then the UPNP should be set up 
	# and people should be able to connect to the host:
	# print external face IP that people should be type in the join Address field
	print("Success Join Adress: %s" %upnp.query_external_address())
