extends KinematicBody2D

export var key = "0"
export var speed = 200
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

onready var nav : Navigation2D = get_parent().get_child(0)
onready var map : TileMap = nav.get_child(0)
onready var machines : Array = get_parent().machines
onready var colors : Array = get_parent().lineColors

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect('dispatch_mechanic', self, "dispatch_mechanic")  # Replace with function body.
	get_parent().connect('remove_mechanic', self, "remove_mechanic")
	get_parent().connect('update_future_visits', self, "update_future_visits")
	focusLine.width = 15
	futureLine.width = 5
	colors[key]
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
			var dxy = Vector2(-1 if self.position.x - focusPath[0].x <=0 else 1, -1 if self.position.y - focusPath[0].y <= 0 else 1)
			h = "left" if abs(dxy.angle()) < 1 else "right"
			v = "up" if dxy.angle() > 0 else "down"
			$Sprite/anim.play("walk-%s-%s" % [v, h])
			self.position = self.position.linear_interpolate(focusPath[0], (speed * delta)/d)
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
	futureLine.points = futurePath
	futureLine.show()	
		
	
func dispatch_mechanic(data):
	if String(data.mechanic.mechanicIndex) == String(self.key):
#		print("DISPATCH", data);
		if data.mechanic.focusMachineIndex != focusMachineIndex:
			focusMachineIndex = data.mechanic.focusMachineIndex
			focus = machines[focusMachineIndex].coords
			focusPath = nav.get_simple_path(self.position, focus)
			focusLine.points = focusPath
			focusLine.show()

		originalMachineIndex = data.mechanic.originalMachineIndex
		focusFixDurationMillis = data.mechanic.focusFixDurationMillis
		focusTravelDurationMillis = data.mechanic.focusTravelDurationMillis
		

func update_future_visits(data):
	if String(data.mechanicIndex) == String(self.key):
		futureMachineIndexes = data.futureMachineIndexes
		futurePath = []
		var p0 = focus
		for p in futureMachineIndexes:
			self.futurePath.append_array(nav.get_simple_path(p0, machines[p].coords))
			p0 = machines[p].coords
		#print(futurePath)
		futureLine.show()

func remove_mechanic(data):
	if  String(data.key) == String(self.key):
		focus = machines[machines.size()-1].coords
		focusPath = nav.get_simple_path(self.position, focus)
		focusLine.points = focusPath
		focusLine.show()

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