extends KinematicBody2D

export var key = "0"

signal repairing_machine
signal fixed_machine

onready var wayPointNode = preload("res://scenes/waypoint.tscn")
onready var spawn : Position2D = get_node("/root/Dashboard/mechanic_spawn")
onready var pathNode = preload("res://sprites/future-dot.png")

const futureColors = PoolColorArray([Color(255,0,0,1.0), Color(0,1,0,1.0), Color(0.5,.75,1.0,1), Color(1.75, 0.75, 0.1, 1.0), Color(.5,.5,.5,1.0)])
const focusColors = PoolColorArray([Color(.678,.11,.11,.5), Color(.2,.6,.2,.5), Color(0.18,.396,.604,.5), Color(.918,.255,.075,.5), Color(.302,.357,.4,.5)])
const mechanicColors = [Color(2,0,0,1.0), Color(0,1.5,0,1.0),Color(0.6,1.2,2.2,1.0),Color(2.8, 1.05, .2, 1.0),Color(1.05,1.15,1.25,1.0)]

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
var focusWaypoint

onready var nav : Navigation2D = get_node("/root/Dashboard/Navigation2D")
onready var map : TileMap = get_node("/root/Dashboard/Navigation2D/TileMap")
onready var Dashboard = get_node("/root/Dashboard")
onready var machines : Array = Dashboard.get_node('machines').get_children()
onready var waypointNode = get_node("/root/Dashboard/waypoints")

# Called when the node enters the scene tree for the first time.
func _ready():
	var pathColor = futureColors[int(key) % 5]
	set_physics_process(true)
	Dashboard.connect('dispatch_mechanic', self, "dispatch_mechanic")
	Dashboard.connect('remove_mechanic', self, "remove_mechanic")
	Dashboard.connect('update_future_visits', self, "update_future_visits")
	focusLine.texture = pathNode
	futureLine.texture = pathNode
	focusLine.default_color = pathColor
	futureLine.default_color = pathColor
	$img.material = $img.material.duplicate()
	$img.material.set_shader_param("coverall_color", mechanicColors[int(key) % 5])
	waypoints = [createWaypoint(1, spawn, spawn, mechanicColors[int(key) % 5]), createWaypoint(2, spawn, spawn, mechanicColors[int(key) % 5]), createWaypoint(3, spawn, spawn, mechanicColors[int(key) % 5])]
	focusWaypoint = createWaypoint(0, spawn, spawn, mechanicColors[int(key) % 5])
	waypointNode.add_child(focusWaypoint)
	Dashboard.add_child(focusLine)
	Dashboard.add_child(futureLine)

func _init():
	focusLine.z_index = 1
	focusLine.width = 30
	focusLine.texture_mode = Line2D.LINE_TEXTURE_TILE
	focusLine.joint_mode = Line2D.LINE_JOINT_SHARP
	focusLine.end_cap_mode = Line2D.LINE_CAP_NONE
	focusLine.begin_cap_mode = Line2D.LINE_CAP_NONE
	
	futureLine.z_index = 1
	futureLine.width = 30
	futureLine.texture_mode = Line2D.LINE_TEXTURE_TILE
	futureLine.joint_mode = Line2D.LINE_JOINT_ROUND
	futureLine.end_cap_mode = Line2D.LINE_CAP_ROUND
	futureLine.begin_cap_mode = Line2D.LINE_CAP_BOX
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if global_position.y > 775:
		self.z_index = 19
	elif global_position.x < 800 and global_position.y > 600:
		self.z_index = 17
	elif global_position.y > 500 and (global_position.x < 945 or global_position.y > 680):
		self.z_index = 13
	elif global_position.y > 365 and global_position.x > 400:
		self.z_index = 11
	else:
		self.z_index = 5

	if !focusPath:
		focusLine.hide()
		focusWaypoint.hide()
		if key == "99":
			get_parent().remove_child(self)
		if $clock.time_left <= 0 and !repairing:
			$clock.wait_time = focusFixDurationMillis/1000
			$clock.start()
			emit_signal("repairing_machine", focusMachineIndex)
			repairing = true
	if focusPath.size() > 0:
		var d: float = self.position.distance_to(focusPath[0])
		if d > 10:
			var dxy = Vector2(-1 if self.position.x - focusPath[0].x <=0 else 1, -1 if self.position.y - focusPath[0].y <= 0 else 1)
			h = "left" if abs(dxy.angle()) < 1 else "right"
			v = "up" if dxy.angle() > 0 else "down"
			$img/anim.play("walk-%s-%s" % [v, h])
			self.position = self.position.linear_interpolate(focusPath[0], (velocity * delta)/d)
			focusTravelDurationMillis -= delta
			var focusLineArray = focusPath
			focusLineArray.insert(0, position)
			focusLine.points = focusLineArray
		else:
			focusPath.remove(0)
			var machine = machines[focusMachineIndex]
			var pos = machine.offset if machine.get('offset') else Vector2(machine.position.x+20, machine.position.y+20)
			var mxy = Vector2(-1 if self.position.x - pos.x <=0 else 1, -1 if self.position.y - pos.y <= 0 else 1)
			h = "left" if abs(mxy.angle()) < 1 else "right"
			v = "up" if mxy.angle() > 0 else "down"
			$img/anim.play("wait-%s-%s" % [v, h])
			update_future_visits({"mechanicIndex": self.key, "futureMachineIndexes": futureMachineIndexes})
	for wp in range(futureMachineIndexes.size()):
		waypoints[wp].show()
	
	futureLine.points = futurePath
	futureLine.show()	
		
	
func dispatch_mechanic(data):
	if String(data.key) == String(self.key):
		originalMachineIndex = data.value.mechanic.originalMachineIndex
		focusFixDurationMillis = data.value.mechanic.focusFixDurationMillis
		focusTravelDurationMillis = data.value.mechanic.focusTravelDurationMillis if data.value.mechanic.focusTravelDurationMillis > 0 else 200.0
		focusMachineIndex = data.value.mechanic.focusMachineIndex
		focus = machines[focusMachineIndex].repair if machines[focusMachineIndex].get('repair') else machines[focusMachineIndex].position
		velocity = getTotalDistance(self.position, focus)/(focusTravelDurationMillis/1000.0)
		focusPath = nav.get_simple_path(self.position, focus)
		focusLine.points = focusPath
		focusLine.show()
		focusWaypoint.position = focus
		focusWaypoint.show()
		repairing = false
		emit_signal("fixed_machine", originalMachineIndex)

func update_future_visits(data):
	if String(data.mechanicIndex) == String(self.key):
		futureMachineIndexes = data.futureMachineIndexes
		futurePath = []
		var p0 = focus
		for wp in range(waypoints.size()-futureMachineIndexes.size()):
				waypoints[-wp].hide()
		for p in range(futureMachineIndexes.size()):
			var machineIdx = futureMachineIndexes[p]
			waypoints[p].position = machines[machineIdx].repair if machines[machineIdx].get('repair') else machines[machineIdx].position
			self.futurePath.append_array(nav.get_simple_path(p0, machines[machineIdx].repair if machines[machineIdx].get('repair') else machines[machineIdx].position))
			p0 = machines[machineIdx].repair
		#print(futurePath)

func createWaypoint(order, start, goal, color):
	var wp = wayPointNode.instance()
	wp.wp_number = order
	#wp.get_child(1).text = String(order+1)
	wp.start = start
	wp.goal = goal
	wp.color = color
	wp.z_index = 50
	waypointNode.add_child(wp)
	return wp

func remove_mechanic(data):
	if  String(data.key) == String(self.key):
		self.key = "99"
		emit_signal("fixed_machine", focusMachineIndex)
		focus = spawn.position
		focusPath = nav.get_simple_path(self.position, focus)
		Dashboard.remove_child(futureLine)
		Dashboard.remove_child(focusLine)
		for wp in waypoints:
			wp.get_parent().remove_child(wp)
		futureMachineIndexes = []

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