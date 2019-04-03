extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect('dispatch_mechanic', self, "dispatch_mechanic")  # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func dispatch_mechanic(data):
	print(data);
#	pass
	
#if event is InputEventMouseButton:
#		if event.button_index == BUTTON_LEFT and event.pressed:
#			goal = event.position
#			print(nav.get_child(0).world_to_map(goal))
#			path = nav.get_simple_path($Mechanic.position, goal)
#			$Line2D.points = path
#			$Line2D.show()
#			if path:
#				emit_signal("mechanic_embark", {
#					"mechanic_id": 0,
#					"machine_id": 0,
#					"pos_start": $Mechanic.position,
#					"pos_end": path[-1],
#					"pos_target": event.position,
#					"path": path
#				})