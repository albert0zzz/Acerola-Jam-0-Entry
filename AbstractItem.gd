extends RigidBody3D
class_name Cube

@onready var player: CharacterBody3D = $"../Player"
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export var stats: Item
@export var skill: Skill

func _ready() -> void:
	if stats != null:
		mesh_instance_3d.set_surface_override_material(0, stats.material)

