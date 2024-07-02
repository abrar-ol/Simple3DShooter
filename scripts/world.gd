extends Node3D

# $MultiplayerSpawner: uesed because with out it
# the host contolling both client and server and both spawn in the server
# 1- add spawn path: we are instanceing the players as a child of World node
# 2- auto spawn list: add player secene ( what we want to spawn )
# 3- in the player script: server and client can only control their corresponding players 
# by set up the authority and connect it to their corresponding peer

@onready var main_menu = $CanvasLayer/MainMenu
@onready var adress_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AdressEntry

var enet_peer = ENetMultiplayerPeer.new()

const PORT = 9999
const PLAYER = preload("res://scenes/player.tscn")

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_host_button_pressed():
	main_menu.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player) #  When player press join --> add player
	# (wire up a signal) peer_connected is a signal thet is going to emmit 
	# at a server every time a client connect to it
	# it connects add_player, it's gonna pass in the new peer id
	add_player(multiplayer.get_unique_id())

func _on_join_button_2_pressed():
	main_menu.hide()
	enet_peer.create_client("localhost",PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	print(peer_id)
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)
