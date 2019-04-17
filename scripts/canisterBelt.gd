extends Path2D

onready var canisterNode = preload("res://scenes/canister_ph.tscn")
onready var flow : Timer = $canister_flow
export var canisters : int = 20
export var speed : int = 45

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	spawnCanister()

func spawnCanister():
	var new_canister : PathFollow2D = canisterNode.instance()
	new_canister.position = $spawn.position
	new_canister.z_index = 5	
	self.add_child(new_canister)
#	var tween = Tween.new()
#	add_child(tween)
#	tween.interpolate_property(new_canister, "unit_offset", 
#								0, 1, speed, 
#								tween.TRANS_LINEAR, 
#								tween.EASE_IN_OUT)
#	tween.repeat = true
#	tween.start()

func _on_canister_flow_timeout():
	$pusher/anim.play("push")
	spawnCanister()