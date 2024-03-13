extends RigidBody3D
var satisfied: bool = false
@onready var level: Node3D = $".."
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var player: CharacterBody3D = $"../Player"

func _on_body_entered(body: Node) -> void:
	if body is Cube and body.pickable == true:
		if satisfied == false:
			body.pickable = false
			audio_player.play()
			satisfied = true
			player.citizen_amount -= 1
			print(player.citizen_amount)
