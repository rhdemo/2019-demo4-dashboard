extends Sprite

# Declare member variables here. Examples:
export (Vector2) var heal_coords = Vector2(0,0);
export (Color) var color = Color.red
export (float) var health = 100;
export (Vector2) var direction = Vector2(0,0)
export var MAX_HEALTH : int = 100
export var HEALTHY_MIN_PCT : int = 90
export var DAMAGE_MIN_PCT : int = 50
export (Vector2) var repair = Vector2(0,0)
onready var healthNode : Sprite = find_node("health")
onready var lightNode : Sprite = find_node("light")
onready var repairNode: Position2D = find_node("repair")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Dashboard").connect("machine_health", self, "_on_machine_health")
	get_node("/root/Dashboard").connect("repairing_machine", self, "_on_repair_machine")
	get_node("/root/Dashboard").connect("fixed_machine", self, "_on_fix_machine")
	if repairNode:
		repair = repairNode.global_position
	if healthNode:
		if healthNode["IS_HEALTHY"]:
			healthNode["IS_HEALTHY"] = HEALTHY_MIN_PCT
		if healthNode["IS_DAMAGED"]:
			healthNode["IS_DAMAGED"] = DAMAGE_MIN_PCT

func _process(delta):
	if lightNode:
		if (health/MAX_HEALTH)*100 >= HEALTHY_MIN_PCT:
			lightNode.get_child(0).play("healthy")
		elif (health/MAX_HEALTH)*100 > DAMAGE_MIN_PCT:
			lightNode.get_child(0).play("damaged")
		else:
			lightNode.get_child(0).play("alert")
	if healthNode:
		healthNode.health = (health/MAX_HEALTH)*100
	#print(machine_name, " HEALTH:", $health.health)

func _on_repair_machine(machineIdx):
	if machineIdx == get_position_in_parent():
		healthNode.repair = true

func _on_fix_machine(machineIdx):
	if machineIdx == get_position_in_parent():
		healthNode.repair = false

func _on_machine_health(data):
	if data.id == self.name:
		health = data.percent if data.has('percent') else data.value
