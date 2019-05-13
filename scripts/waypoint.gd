extends Node2D

export var wp_number = 0
export (Vector2) var start
export (Vector2) var goal
export (float) var timing = 1000
export (Color) var color = Color(2,0,0,1.0)
export (bool) var faded = true
var fadeState = true
#onready var waypoint1 = preload("res://sprites/mechanic/1.png")
#onready var nav : Navigation2D = get_node("/root/Dashboard/Navigation2D")
var waypoints = [preload("res://sprites/mechanic/0.png"),preload("res://sprites/mechanic/1.png"),preload("res://sprites/mechanic/2.png"),preload("res://sprites/mechanic/3.png"),
preload("res://sprites/mechanic/4.png"), preload("res://sprites/mechanic/5.png")]

var path : PoolVector2Array
var velocity = 0

# Called when the node enters the scene tree for the first time.
func _ready():
#	$number.text = String(wp_number)
	$sprite.material.set_shader_param("blend_color", color)
	$sprite.texture =waypoints[wp_number]
	#path = nav.get_simple_path(start, goal)
	#velocity = getTotalDistance(self.position, start)/(timing/1000.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$sprite.texture =waypoints[wp_number]
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
	#$sprite.texture =waypoints[wp_number]
	
	#position.linear_interpolate(goal, timing)
#	if !path:
#		$trail.points = []
#		get_parent().remove_child(self)
#	if path.size() > 0:
#		var d: float = self.position.distance_to(path[0])
#		if d > 10:
#			self.position = self.position.linear_interpolate(path[0], (velocity * delta)/d)
#		else:
#			path.remove(0)

#func getTotalDistance(start:Vector2, goal:Vector2):
#	var dist = 0
#	if start != goal:
#		if path.size() > 0:
#			var strt = path[0] #map.map_to_world(pth[0])
#			for wp in path:
#				var diff = strt.distance_to(wp)
#				dist += diff
#				strt = wp
#	dist = dist if dist != 0 else 200
#	return dist