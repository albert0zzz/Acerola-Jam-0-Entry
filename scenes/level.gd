extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var player_timer: Timer = $Player/PlayerTimer
@onready var timer_time: Label = $Player/Control/MarginContainer/TimerTime
@onready var win_screen: Control = $CanvasLayer/WinScreen

@export var level_time: float = 60.0
@export var citizen_amount: int = 4

var start_level: bool = false

func _ready() -> void:
	start_level = false
	player_timer.wait_time = level_time
	player.citizen_amount = citizen_amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if start_level == true:
		player_timer.start()
		timer_time.visible = true
		start_level == false
		set_process(false)
