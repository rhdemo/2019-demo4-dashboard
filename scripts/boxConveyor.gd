extends Path2D

onready var boxNode = preload("res://scenes/box_ph.tscn")
onready var flow : Timer = $box_flow
export var boxes : int = 11
export var speed : int = 60

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	spawnBox()

func spawnBox():
	var new_box : PathFollow2D = boxNode.instance()
	new_box.position = $spawn.position
	new_box.z_index = 0
	self.add_child(new_box)
#	var tween = Tween.new()
#	add_child(tween)
#	tween.interpolate_property(new_box, "unit_offset", 
#								0, 1, speed, 
#								tween.TRANS_LINEAR, 
#								tween.EASE_OUT_IN)
#	tween.repeat = true
#	tween.start()

func _on_flow_timeout():
	spawnBox()
#	if boxes > 0:
#		spawnBox()
#		boxes -= 1
#		flow.start()
