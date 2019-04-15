extends Path2D

onready var canisterNode = preload("res://scenes/canister.tscn")
onready var flow : Timer = $canister_flow
export var canisters : int = 20
export var speed : int = 45

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	spawnCanister()

func spawnCanister():
	var new_canister : PathFollow2D = canisterNode.instance()
	new_canister.z_index = 9
	self.add_child(new_canister)
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(new_canister, "unit_offset", 
								0, 1, speed, 
								tween.TRANS_LINEAR, 
								tween.EASE_IN_OUT)
	tween.repeat = true
	tween.start()

func _on_canister_flow_timeout():
	if canisters > 0:
		spawnCanister()
		canisters -= 1
		flow.start()