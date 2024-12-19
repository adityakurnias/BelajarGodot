class_name WalkingState
extends State

func update(_delta):
	if Global.player.velocity.length() == 0.0:
		transition.emit("IdleState")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("sprint") and Global.player.is_on_floor():
		transition.emit("SprintState")
