extends Button

@onready var player: CharacterBody3D = $"../../.."
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var timer: Timer = $Timer
@onready var hotbar: HBoxContainer = $".."

var time_remaining: float = 0.0

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

func _process(delta: float) -> void:
	progress_bar.value = timer.time_left

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact_Key") and !(player.ray_hit.get_collider() is Cube):
		pass
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
	

