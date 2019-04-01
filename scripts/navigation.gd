extends Node2D

onready var mechanicNode = preload("res://mechanic.tscn")
#onready var machineNode = preload("res://machine.tscn")
onready var nav : = $Navigation2D
onready var map : = $Navigation2D/TileMap


var lines = []
var path : PoolVector2Array
var goal : Vector2
export var speed := 250
var mechanics = []
var machines = {
	"machine-a": { "coords": Vector2(5,2), "color": Color.yellow},
	"machine-b": { "coords": Vector2(11,-4), "color": Color.green},
	"machine-c": { "coords": Vector2(11, -7), "color": Color.purple},
	"machine-d": { "coords": Vector2(14,-11), "color": Color.pink},
	"machine-e": { "coords": Vector2(15,-4), "color": Color.black},
	"machine-f": { "coords": Vector2(19,-4), "color": Color.maroon},
	"machine-g": { "coords": Vector2(20,0), "color": Color.blue},
	"machine-h": { "coords": Vector2(13,6), "color": Color.lightblue},
	"machine-i": { "coords": Vector2(16,10), "color": Color.orange},
	"machine-j": { "coords": Vector2(8,6), "color": Color.red},
	"gate": { "coords": Vector2(14,9), "color": Color.white}
	}
var distance_matrix = "";

signal mechanic_embark
signal mechanic_arrived

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			goal = event.position
			path = nav.get_simple_path($Fedora.position, goal, false)
			$Line2D.points = PoolVector2Array(path)
			$Line2D.show()

func _ready():
	$AddMechanic.connect('pressed', self, "add_mechanic")
#	var pts : PoolVector2Array
	for m in machines:
		var coords = machines[m].coords #map.map_to_world(machines[m].coords)
		coords.y += .5
		machines[m].coords = coords 

func get_distance_matrix_output():
	var csv_array = []
	var headings = ["machine name", "x", "y", "machine-a", "machine-b", "machine-c", "machine-d", "machine-e", "machine-f", "machine-g", "machine-h", "machine-i", "machine-j", "gate"]
	csv_array.append(headings)
	for pt in machines:
		var ptDist = [pt,map.map_to_world(machines[pt].coords).x, map.map_to_world(machines[pt].coords).y]
		var start = machines[pt].coords #$TileMap.map_to_world(machines[pt]);
		for g in machines:
			var goal = machines[g].coords #$TileMap.map_to_world(machines[g])
			var dist = 0
			var pth = nav.get_simple_path(start, goal)
			if start != goal:
				if pth.size() > 0:
					var strt = pth[0] #map.map_to_world(pth[0])
					#var ln = Line2D.new()
					#ln.default_color = machines[pt].color
					for wp in pth:
						#wp = map.map_to_world(wp)
						var diff = strt.distance_to(wp)
						#ln.points.append(strt)
						dist += diff
						strt = wp
					#lines.append(ln)
			ptDist.append(dist)
		csv_array.append(ptDist)
	var prnt = ''
	for ln in csv_array:
		for v in ln:
			prnt += String(v)+","
		prnt += "\n"
	for l in lines:
		l.z_index = 99
		#print(l.points)
		self.add_child(l)
		l.show()
	print(prnt)

func add_mechanic():
	for pt in machines:
		var mechanic = mechanicNode.instance()
		var map_pos = map.map_to_world(machines[pt].coords)
		map_pos.y += 384
		mechanic.position = map_pos #$Navigation2D/TileMap.map_to_world(nav_points[nav_points.size()-1])
		self.add_child(mechanic)
		mechanics.append(mechanic)
	get_distance_matrix_output()
		
func _process(delta: float) -> void:
	if !path:
		$Line2D.hide()
		return
	if path.size() > 0:
		var d: float = $Fedora.position.distance_to(path[0])
		if d > 10:
			$Fedora.position = $Fedora.position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			path.remove(0)
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
