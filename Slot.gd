extends Button

@onready var player: CharacterBody3D = $"../../.."

@export var stats: Item = null:
	set(value):
		stats = value
		
		if value != null:
			icon = value.icon
		else:
			icon = null

@export var skill: Skill = null

func _ready() -> void:
	set_process_input(false)

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("Interact_Key") and !(player.ray_hit.get_collider() is Cube):
		#use_item()
	if event.is_action_pressed("Drop_Key"):
		drop_item()

#func use_item():
	#if stats == null:
		#return
	#player.handle_skill(skill)

func drop_item():
	if stats == null:
		return
	player.drop_item(stats, skill)
	
