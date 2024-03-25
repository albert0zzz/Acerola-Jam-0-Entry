extends RigidBody3D
@onready var timer: Timer = $Timer
@export var lifetime: float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(lifetime)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer.is_stopped():
		queue_free()
