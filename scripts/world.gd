extends Node3D

@onready var main_menu = $CanvasLayer/MainMenu
@onready var adress_entry = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/AdressEntry
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
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())

func _on_join_button_2_pressed():
	main_menu.hide()
	enet_peer.create_client("localhost",PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)
