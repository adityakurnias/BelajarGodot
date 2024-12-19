extends PanelContainer

@onready var property_container = %VBoxContainer
var property
var fps : String

func _ready() -> void:
	visible = false
	
	# Set global reference to self
	Global.debug = self
	  

func _process(delta: float) -> void:
	if visible:
		fps = "%.2f" % (1.0/delta) 
		add_property("FPS", fps, 0)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug"):
		visible = !visible
		
func add_property(title : String, value, order):
	var target
	target = property_container.find_child(title, true, false)
	if !target:
		target = Label.new()
		property_container.add_child(target)
		target.name = title
		target.text = target.name + ": " + str(value)
	else:
		target.text = title + ": " + str(value)
		property_container.move_child(target, order)
