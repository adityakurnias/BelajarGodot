class_name StateMachine
extends Node

@export var CurrentState: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
		else:
			push_warning("State machine contain incompatible node")
	CurrentState.enter()

func _process(delta: float) -> void:
	CurrentState.update(delta)
	Global.debug.add_property("Current State", CurrentState.name, 8)

func _physics_process(delta: float) -> void:
	CurrentState.physics_update(delta)

func on_child_transition(new_state_name: StringName):
	var new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != CurrentState:
			CurrentState.exit()
			new_state.enter()
			CurrentState = new_state
	else:
		push_warning("State not exist")
