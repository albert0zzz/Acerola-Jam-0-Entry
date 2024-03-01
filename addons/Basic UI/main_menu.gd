extends Control

@onready var Game_Scene_Route: Resource = preload("res://scenes/level_1.tscn")
@onready var play_button: Button = $MarginContainer/VBoxContainer/PlayButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_button.grab_focus()


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(Game_Scene_Route)


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_credits_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()
