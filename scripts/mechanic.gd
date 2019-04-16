extends KinematicBody2D

export var key = "0"

onready var wayPointNode = preload("res://scenes/waypoint.tscn")
onready var spawn : Position2D = get_node("/root/Dashboard/mechanic_spawn")

const futureColors = PoolColorArray([Color(255, 0,0, .5), Color(0,255,0,.5), Color(0,0,255,.5), Color(255,100,100,.5), Color(100,100,255,.5)])
const focusColors = PoolColorArray([Color(255, 0, 0, .5), Color(0,255,0,.5), Color(0,0,255,.5), Color(255,100,100,.5), Color(100,100,255,.5)])
const mechanicColors = [{"red":4},{"green":1},{"blue":0},{"black":3},{"orange":2}]

# Declare member variables here. Examples:
var focusMachineIndex : int
var futureMachineIndexes = []
var originalMachineIndex : int
var focusTravelDurationMillis: int
var focusFixDurationMillis : int
var focusPath : PoolVector2Array
var futurePath : PoolVector2Array
var focusLine : = Line2D.new()
var futureLine : = Line2D.new()
var focus : Vector2
var h = "right"
var v = "up"
var velocity = 0
var waypoints = []

onready var nav : Navigation2D = get_node("/root/Dashboard/Navigation2D")
onready var map : TileMap = get_node("/root/Dashboard/Navigation2D/TileMap")
onready var Dashboard = get_node("/root/Dashboard")
onready var machines : Array = Dashboard.get_node('machines').get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	Dashboard.connect('dispatch_mechanic', self, "dispatch_mechanic")
	Dashboard.connect('remove_mechanic', self, "remove_mechanic")
	Dashboard.connect('update_future_visits', self, "update_future_visits")
	focusLine.default_color = focusColors[int(key) % 5]
	futureLine.default_color = futureColors[int(key) % 5]
	
	waypoints = [wayPointNode.instance(), wayPointNode.instance(), wayPointNode.instance(), wayPointNode.instance()]

	for wp in waypoints:
		wp.get_child(0).modulate = futureColors[int(key)]
		wp.z_index = 12
		Dashboard.add_child(wp)
		wp.hide()
	Dashboard.add_child(focusLine)
	Dashboard.add_child(futureLine)

func _init():
	focusLine.z_index = 1
	focusLine.width = 15
	focusLine.joint_mode = Line2D.LINE_JOINT_ROUND
	focusLine.end_cap_mode = Line2D.LINE_CAP_ROUND
	focusLine.begin_cap_mode = Line2D.LINE_CAP_BOX
	
	futureLine.z_index = 1
	futureLine.width = 5
	futureLine.joint_mode = Line2D.LINE_JOINT_ROUND
	futureLine.end_cap_mode = Line2D.LINE_CAP_ROUND
	futureLine.begin_cap_mode = Line2D.LINE_CAP_BOX
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global_position.y > 930:
		self.z_index = 12
	elif global_position.y > 900:
		self.z_index = 10
	elif global_position.y > 650 or (global_position.y > 300 and global_position.x < 500):
		self.z_index = 8
	elif global_position.y > 300 and global_position.x < 500:
		self.z_index = 6
	elif global_position.y > 300:
		self.z_index = 4
	else:
		self.z_index = 0
		
	#print(z_index)
	if !focusPath:
		focusLine.hide()
	if focusPath.size() > 0:
		var d: float = self.position.distance_to(focusPath[0])
		if d > 10:
			var dxy = Vector2(-1 if self.position.x - focusPath[0].x <=0 else 1, -1 if self.position.y - focusPath[0].y <= 0 else 1)
			h = "left" if abs(dxy.angle()) < 1 else "right"
			v = "up" if dxy.angle() > 0 else "down"
			$Sprite/anim.play("walk-%s-%s" % [v, h])
			self.position = self.position.linear_interpolate(focusPath[0], (velocity * delta)/d)
			focusTravelDurationMillis -= delta
		else:
			focusPath.remove(0)
			if $Sprite/anim.current_animation == "walk-up-left":
				$Sprite/anim.play("wait-up-left")
			elif $Sprite/anim.current_animation == "walk-up-right":
				$Sprite/anim.play("wait-up-right")
			elif $Sprite/anim.current_animation == "walk-down-left":
				$Sprite/anim.play("wait-down-left")
			else:			
				$Sprite/anim.play("wait-down-right")
	else:
		if position == spawn.position:
			get_parent().remove_child(self)
	for wp in range(futureMachineIndexes.size()):
		waypoints[wp].get_child(1).text = String(wp+1)
		waypoints[wp].show()
	futureLine.points = futurePath
	futureLine.show()	
		
	
func dispatch_mechanic(data):
	#print(data.key, " - ", self.key)
	if String(data.key) == String(self.key):
		originalMachineIndex = data.value.mechanic.originalMachineIndex
		focusFixDurationMillis = data.value.mechanic.focusFixDurationMillis
		focusTravelDurationMillis = data.value.mechanic.focusTravelDurationMillis if data.value.mechanic.focusTravelDurationMillis > 0 else 200.0
		focusMachineIndex = data.value.mechanic.focusMachineIndex
		focus = machines[focusMachineIndex].heal_coords if machines[focusMachineIndex].get('heal_coords') else machines[focusMachineIndex].position
		velocity = getTotalDistance(self.position, focus)/(focusTravelDurationMillis/1000.0)
		focusPath = nav.get_simple_path(self.position, focus)
		focusLine.points = focusPath
		focusLine.show()

func update_future_visits(data):
	if String(data.mechanicIndex) == String(self.key):
		futureMachineIndexes = data.futureMachineIndexes
		futurePath = []
		var p0 = focus
		for wp in waypoints:
			wp.hide()
		for p in range(futureMachineIndexes.size()):
			var machineIdx = futureMachineIndexes[p]
			waypoints[p].position = machines[machineIdx].heal_coords if machines[machineIdx].get('heal_coords') else machines[machineIdx].position
		
			self.futurePath.append_array(nav.get_simple_path(p0, machines[machineIdx].heal_coords if machines[machineIdx].get('heal_coords') else machines[machineIdx].position))
			p0 = machines[machineIdx].heal_coords
		#print(futurePath)

func remove_mechanic(data):
	if  String(data.key) == String(self.key):
		self.key = "99"
		focus = spawn.position
		focusPath = nav.get_simple_path(self.position, focus)
		Dashboard.remove_child(futureLine)
		Dashboard.remove_child(focusLine)

func getTotalDistance(start:Vector2, goal:Vector2):
	var path = nav.get_simple_path(start, goal)
	var dist = 0
	if start != goal:
		if path.size() > 0:
			var strt = path[0] #map.map_to_world(pth[0])
			for wp in path:
				var diff = strt.distance_to(wp)
				dist += diff
				strt = wp
	dist = dist if dist != 0 else 999
	return dist

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