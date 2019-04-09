extends Area2D

signal machine_damaged
signal machine_repaired

export (float) var health = 1.0;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		health -= .05
		#print(health)
		emit_signal("machine_damaged", true)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass