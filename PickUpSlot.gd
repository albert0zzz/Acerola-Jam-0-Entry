extends Node3D

var current_index: int = 0

func reset():
	var weapons = get_children()
	for weapon in weapons:
		weapon.hide()

func show_weapon(index):
	if index < get_child_count():
		get_child(index).show()

func _on_hotbar_index(i: int = current_index) -> void:
	reset()
	show_weapon(i)
	current_index = i


func _on_child_entered_tree(node: Node) -> void:
	_on_hotbar_index()
