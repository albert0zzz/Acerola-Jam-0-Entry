extends RigidBody3D
class_name Cube

@onready var abstract_item: Cube = $"."

@onready var player: CharacterBody3D = $"../Player"
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var pick_up_slot: Node3D = $"../Player/Head/PickUpSlot"
@onready var hotbar: HBoxContainer = $"../Player/Control/Hotbar"
@onready var level: Node3D = $".."
@onready var head: Node3D = $"../Player/Head"

var hand_item: Object

@export var stats: Item
@export var skill: Skill

func _ready() -> void:
	if stats != null:
		mesh.set_surface_override_material(0, stats.material)

func _on_player_picked_item(object) -> void:
	object.reparent(pick_up_slot, false)
	object.freeze = true
	object.collision.disabled = true
	object.mesh.cast_shadow = false
	object.position = Vector3.ZERO
	object.rotation = Vector3.ZERO
	#player.hand_collision_shape.disabled = false
	#player.hand_collision_shape.shape = object.collision.shape
	player.add_item(object.stats, object.skill)

func _on_player_dropped_item() -> void:
	hand_item = pick_up_slot.get_child(hotbar.current_index)
	hand_item.reparent(level)
	hand_item.freeze = false
	hand_item.collision.disabled = false
	hand_item.mesh.cast_shadow = true
	#hand_collision_shape.disabled = true
	var throw_vector := -head.global_transform.basis.z.normalized()
	hand_item.apply_central_impulse(throw_vector * 15.0 * clamp(player.velocity.length()/6.0,1,3) +\
	Vector3(player.velocity.x / 4.0, player.velocity.y / 7.0 + 1.5, player.velocity.z / 4.0))



func _physics_process(delta: float) -> void:
	#player.hand_collision_shape.global_transform = hand_item.collision.global_transform
	pass
