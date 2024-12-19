class_name SprintState
extends State

func enter() -> void:
	Global.player.speed = Global.player.SPRINT_SPEED

func update(_delta):
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_released("sprint"):
		transition.emit("WalkingState")
