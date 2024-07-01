extends Node3D

@onready var main_menu = $CanvasLayer/MainMenu
@onready var adress_entry = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/AdressEntry


func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _on_host_button_pressed():
	pass # Replace with function body.

func _on_join_button_2_pressed():
	pass # Replace with function body.

