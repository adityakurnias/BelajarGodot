extends CenterContainer

@export var lines : Array[Line2D]
@export var player : CharacterBody3D
@export var crossh_speed : float = 0.25
@export var distance : float = 2.0
@export var dot_radius : float = 1.0
@export var dot_color : Color = Color.WHITE

func _ready() -> void:
	queue_redraw()

func _process(_delta: float) -> void:
	adjust_lines()

func _draw() -> void:
	draw_circle(Vector2(0, 0), dot_radius, dot_color)
	
func adjust_lines() -> void:
	var vel = player.get_real_velocity()
	var origin = Vector3(0, 0, 0)
	var pos = Vector2(0, 0)
	var speed = origin.distance_to(vel)

	lines[0].position = lerp(lines[0].position, pos + Vector2(0, -speed * distance), crossh_speed)
	lines[1].position = lerp(lines[1].position, pos + Vector2(speed * distance, 0), crossh_speed)
	lines[2].position = lerp(lines[2].position, pos + Vector2(0, speed * distance), crossh_speed)
	lines[3].position = lerp(lines[3].position, pos + Vector2(-speed * distance, 0), crossh_speed)
