extends Control

@onready var resume_button: Button = $ColorRect/VBoxContainer/ResumeButton

var _is_paused: bool = false:
	set(value):
		_is_paused = value
		get_tree().paused = _is_paused
		visible = _is_paused


func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_cancel")):
		_is_paused = !_is_paused
		resume_button.grab_focus()
		if (_is_paused):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_resume_button_pressed() -> void:
	_is_paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_main_menu_button_pressed() -> void:
	_is_paused = false
	get_tree().change_scene_to_file("res://addons/Basic UI/main_menu.tscn")


func _on_restart_button_pressed() -> void:
	_is_paused = false
	get_tree().reload_current_scene()
