extends Node2D

onready var nav : Navigation2D = $Navigation2D

var path : PoolVector2Array
var goal : Vector2
export var speed := 250

signal mechanic_embark
signal mechanic_arrived

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			goal = event.position
			print(nav.get_child(0).world_to_map(goal))
			path = nav.get_simple_path($Mechanic.position, goal)
			$Line2D.points = path
			$Line2D.show()
			if path:
				emit_signal("mechanic_embark", {
					"mechanic_id": 0,
					"machine_id": 0,
					"pos_start": $Mechanic.position,
					"pos_end": path[-1],
					"pos_target": event.position,
					"path": path
				})

func _process(delta: float) -> void:
	if !path:
		emit_signal("no path")
		return
	if path.size() > 0:
		var d: float = $Mechanic.position.distance_to(path[0])
		if d > 10:
			$Mechanic.position = $Mechanic.position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			path.remove(0)
	if path.size() == 0:
		emit_signal("mechanic_arrived", {
			"mechanic_id": 0,
			"machine_id": 0
		})


#extends Node2D
#
#onready var nav_2d : Navigation2D = $Navigation2D
#onready var line_2d : Line2D = $Line2D
#onready var character : Sprite = $Fedora
#
#func _unhandled_input(event: InputEvent) -> void:
#	if not event is InputEventMouseButton:
#		return
#	if event.button_index != BUTTON_LEFT or not event.pressed:
#		return
#	var new_path : = nav_2d.get_simple_path(character.global_position, event.global_position)
#	line_2d.points = new_path
#	character.path = new_path
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta):
##	pass


func _on_Node2D_mechanic_embark(data):
	print("mechanic_embark: %s" % data)


func _on_Node2D_mechanic_arrived(data):
	print("mechanic_arrived: %s" % data)
	$Line2D.hide()
