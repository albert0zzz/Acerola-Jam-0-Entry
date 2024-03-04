extends Resource
class_name Item

@export var icon: Texture2D
@export var name: String
@export var color: Color
@export var material: StandardMaterial3D
@export var pickable: bool = true

@export_multiline var description: String
