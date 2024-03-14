extends Node3D
@onready var marker_3d: Marker3D = $Marker3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	marker_3d.rotation.z += .9 * delta
	marker_3d.rotation.y += .2 * delta
