extends Navigation2D

onready var mechanicNode = preload("res://mechanic.tscn")
onready var machineNode = preload("res://machine.tscn")

var path : PoolVector2Array
var goal : Vector2
export var speed := 250
var mechanics = []
var machines = {
	"machine-a": Vector2(8,4),
	"machine-b": Vector2(18,-4),
	"machine-c": Vector2(18, -11),
	"machine-d": Vector2(21,-15),
	"machine-e": Vector2(22,-4),
	"machine-f": Vector2(28,-4),
	"machine-g": Vector2(28,2),
	"machine-h": Vector2(21,10),
	"machine-i": Vector2(22,16),
	"machine-j": Vector2(11,10),
	"gate": Vector2(2,4)
	}
var distance_matrix = "";

signal mechanic_embark
signal mechanic_arrived

func _input(event: InputEvent):
	pass

func _ready():
	$AddMechanic.connect('pressed', self, "add_mechanic")

func get_distance_matrix_output():
	var csv_array = []
	var headings = ["machine name", "x", "y", "machine-1", "machine-2", "machine-3", "machine-4", "machine-5", "machine-6", "machine-7", "machine-8", "machine-9", "machine-10", "gate"]
	csv_array.append(headings)
	for pt in machines:
		var ptDist = [pt,$TileMap.map_to_world(machines[pt]).x, $TileMap.map_to_world(machines[pt]).y+26.5]
		var start = machines[pt] #$TileMap.map_to_world(machines[pt]);
		start.y += 26.5
		for g in machines:
			var goal = machines[g] #$TileMap.map_to_world(machines[g])
			goal.y += 26.5
			var pth = get_simple_path(start, goal)
			#print("PATH: ",pth)
			var dist = 0
			if pth.size() > 0:
				var prev = pth[0]
				for wp in pth:
					#print("Dist: ",dist)
					var diff = prev.distance_to(wp)
					dist = dist + diff
					prev = wp
			ptDist.append(dist)
		csv_array.append(ptDist)
	var prnt = ''
	for ln in csv_array:
		for v in ln:
			prnt += String(v)+","
		prnt += "\n"
	print(prnt)

func add_mechanic():
	for pt in machines:
		var mechanic = mechanicNode.instance()
		var map_pos = $TileMap.map_to_world(machines[pt])
		mechanic.position = Vector2(map_pos.x, map_pos.y+26.5) #$Navigation2D/TileMap.map_to_world(nav_points[nav_points.size()-1])
		$TileMap.add_child(mechanic)
		mechanics.append(mechanic)
	get_distance_matrix_output()
		
func _process(delta: float) -> void:
	pass
#	if !path:
#		emit_signal("no path")
#		return
#	if path.size() > 0:
#		var d: float = $Mechanic.position.distance_to(path[0])
#		if d > 10:
#			$Mechanic.position = $Mechanic.position.linear_interpolate(path[0], (speed * delta)/d)
#		else:
#			path.remove(0)
#	if path.size() == 0:
#		emit_signal("mechanic_arrived", {
#			"mechanic_id": 0,
#			"machine_id": 0
#		})


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
