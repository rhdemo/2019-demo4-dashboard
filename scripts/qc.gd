extends KinematicBody2D

var key = "3279"

onready var wayPointNode = preload("res://scenes/waypoint.tscn")
onready var spawn : Position2D = get_node("/root/Dashboard/mechanic_spawn")
onready var nav : Navigation2D = get_node("/root/Dashboard/Navigation2D")
onready var map : TileMap = get_node("/root/Dashboard/Navigation2D/TileMap")
onready var Dashboard = get_node("/root/Dashboard")
onready var machines : Array = Dashboard.get_node('machines').get_children()

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
var repairing = false
var velocity = 0
var waypoints = []


# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
	position = machines[10].position
	focusLine.default_color = Color(.918,.255,.075,.5)
	futureLine.default_color = Color(.918,.255,.075,.5)
	
	originalMachineIndex = 10
	focusFixDurationMillis = 2200.0
	focusTravelDurationMillis = 19987.0
	focusMachineIndex = 8
	futureMachineIndexes = [3, 5, 7]
	focus = machines[focusMachineIndex].get('repair') if machines[focusMachineIndex].get('repair') else machines[focusMachineIndex].position
	velocity = getTotalDistance(self.position, focus)/(focusTravelDurationMillis/1000.0)
	focusPath = nav.get_simple_path(self.position, focus)
	focusLine.points = focusPath
	focusLine.show()
	repairing = false
	
	waypoints = [wayPointNode.instance(), wayPointNode.instance(), wayPointNode.instance(), wayPointNode.instance()]

	for wp in waypoints:
		wp.get_child(0).modulate = Color(.918,.255,.075,.5)
		wp.z_index = 16
		Dashboard.add_child(wp)
		wp.hide()
		
	futurePath = []
	var p0 = focus
	for wp in waypoints:
		wp.hide()
	for p in range(futureMachineIndexes.size()):
		var machineIdx = futureMachineIndexes[p]
		waypoints[p].position = machines[machineIdx].repair if machines[machineIdx].get('repair') else machines[machineIdx].position
	
		self.futurePath.append_array(nav.get_simple_path(p0, machines[machineIdx].repair if machines[machineIdx].get('repair') else machines[machineIdx].position))
		p0 = machines[machineIdx].repair
	Dashboard.add_child(focusLine)
	Dashboard.add_child(futureLine)

func _init():
	focusLine.z_index = 1
	focusLine.width = 15
	focusLine.joint_mode = Line2D.LINE_JOINT_ROUND
	focusLine.end_cap_mode = Line2D.LINE_CAP_ROUND
	focusLine.begin_cap_mode = Line2D.LINE_CAP_BOX
	
	futureLine.z_index = 12
	futureLine.width = 5
	futureLine.joint_mode = Line2D.LINE_JOINT_ROUND
	futureLine.end_cap_mode = Line2D.LINE_CAP_ROUND
	futureLine.begin_cap_mode = Line2D.LINE_CAP_BOX
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if global_position.y > 930:
		self.z_index = 12
	elif global_position.y > 900:
		self.z_index = 10
	elif global_position.y > 750 or (global_position.y > 300 and global_position.x < 500):
		self.z_index = 8
	elif global_position.y > 300 and global_position.x < 500:
		self.z_index = 6
	elif global_position.y > 300:
		self.z_index = 4
	else:
		self.z_index = 2

	if !focusPath:
		focusLine.hide()
		if $clock.time_left <= 0 and !repairing:
			$clock.wait_time = focusFixDurationMillis/1000
			$clock.start()
			repairing = true
	if focusPath.size() > 0:
		var d: float = self.position.distance_to(focusPath[0])
		if d > 10:
			var dxy = Vector2(-1 if self.position.x - focusPath[0].x <=0 else 1, -1 if self.position.y - focusPath[0].y <= 0 else 1)
			h = "left" if abs(dxy.angle()) < 1 else "right"
			v = "up" if dxy.angle() > 0 else "down"
			print("walk-%s-%s" % [v, h])
			self.position = self.position.linear_interpolate(focusPath[0], (velocity * delta)/d)
			focusTravelDurationMillis -= delta
		else:
			focusPath.remove(0)
			var machine = machines[focusMachineIndex]
			var mxy = Vector2(-1 if self.position.x - machine.position.x <=0 else 1, -1 if self.position.y - machine.position.y <= 0 else 1)
			h = "left" if abs(mxy.angle()) < 1 else "right"
			v = "up" if mxy.angle() > 0 else "down"
			print("wait-%s-%s" % [v, h])
			update_future_visits({"mechanicIndex": self.key, "futureMachineIndexes": futureMachineIndexes})
#	if position == spawn.position:
#		get_parent().remove_child(self)
	for wp in range(futureMachineIndexes.size()):
		waypoints[wp].get_child(1).text = String(wp+1)
		waypoints[wp].show()
	futureLine.points = futurePath
	futureLine.show()	

func update_future_visits(data):
	if String(data.mechanicIndex) == String(self.key):
		futureMachineIndexes = data.futureMachineIndexes
		futurePath = []
		var p0 = focus
		for wp in waypoints:
			wp.hide()
		for p in range(futureMachineIndexes.size()):
			var machineIdx = futureMachineIndexes[p]
			waypoints[p].position = machines[machineIdx].repair if machines[machineIdx].get('repair') else machines[machineIdx].position
		
			self.futurePath.append_array(nav.get_simple_path(p0, machines[machineIdx].repair if machines[machineIdx].get('repair') else machines[machineIdx].position))
			p0 = machines[machineIdx].repair
		#print(futurePath)

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
	dist = dist if dist != 0 else 200
	return dist
	
func _on_clock_timeout():
	$clock.stop()