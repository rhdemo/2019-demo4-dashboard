extends KinematicBody2D

export var key = "0"
export var speed = 200
# Declare member variables here. Examples:
var focusMachineIndex : int
var futureMachineIndexes = []
var originalMachineIndex : int
var focusFixDurationMillis : int
var focusPath : PoolVector2Array
var futurePath : PoolVector2Array
var focusLine : = Line2D.new()
var futureLine : = Line2D.new()

onready var nav : Navigation2D = get_parent().get_child(0)
onready var map : TileMap = nav.get_child(0)
onready var machines : Array = get_parent().machines
onready var colors : Array = get_parent().lineColors

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect('dispatch_mechanic', self, "dispatch_mechanic")  # Replace with function body.
	get_parent().connect('remove_mechanic', self, "remove_mechanic")
	focusLine.width = 15
	futureLine.width = 5
	focusLine.default_color = colors[key]
	futureLine.default_color = colors[key]
	get_parent().add_child(focusLine)
	get_parent().add_child(futureLine)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !focusPath:
		focusLine.hide()
	if focusPath.size() > 0:
		var d: float = self.position.distance_to(focusPath[0])
		if d > 10:
			self.position = self.position.linear_interpolate(focusPath[0], (speed * delta)/d)
		else:
			focusPath.remove(0)
#	if !futurePath:
#		futureLine.hide()
#	if futurePath.size() > 0:
		
		
	
func dispatch_mechanic(data):
	if String(data.mechanic.mechanicIndex) == String(self.key):
#		print("DISPATCH", data);
		if data.mechanic.focusMachineIndex != focusMachineIndex:
			focusMachineIndex = data.mechanic.focusMachineIndex
			var focus = map.map_to_world(machines[focusMachineIndex].coords)
			focusPath = nav.get_simple_path(self.position, focus)
			focusLine.points = focusPath
			focusLine.show()
		if data.mechanic.futureMachineIndexes != futureMachineIndexes:
			futureMachineIndexes = data.mechanic.futureMachineIndexes
			originalMachineIndex = data.mechanic.originalMachineIndex
			focusFixDurationMillis = data.mechanic.focusFixDurationMillis

func remove_mechanic(data):
	#print("REMOVE", data, self.key);
	if  String(data.key) == String(self.key):
		var focus = map.map_to_world(machines[machines.size()-1].coords)
		focusPath = nav.get_simple_path(self.position, focus)
		focusLine.points = focusPath
		focusLine.show()
#
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