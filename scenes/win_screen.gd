extends Control

@export var Next_level: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://addons/Basic UI/main_menu.tscn")


func _on_next_level_button_pressed() -> void:
	get_tree().change_scene_to_packed(Next_level)
