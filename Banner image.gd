extends Node3D
var red_cube: Resource = preload("res://red_cube.tscn")
var green_cube: Resource = preload("res://green_cube.tscn")
var blue_cube: Resource = preload("res://blue_cube.tscn")
var white_cube: Resource = preload("res://white_cube.tscn")
@onready var marker_3d: Marker3D = $Marker3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var red_cube_instance = red_cube.instantiate()
	var green_cube_instance = green_cube.instantiate()
	var blue_cube_instance = blue_cube.instantiate()
	var white_cube_instance = white_cube.instantiate()
	if Input.is_action_pressed("ui_accept"):
		red_cube_instance.global_position.y = randf_range(4.0,5.5)
		green_cube_instance.global_position.y = randf_range(4.0,5.5)
		blue_cube_instance.global_position.y = randf_range(4.0,5.5)
		white_cube_instance.global_position.y = randf_range(4.0,5.5)
		marker_3d.add_child(red_cube_instance)
		marker_3d.add_child(green_cube_instance)
		marker_3d.add_child(blue_cube_instance)
		marker_3d.add_child(white_cube_instance)
