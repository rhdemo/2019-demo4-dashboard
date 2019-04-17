extends Sprite

# Declare member variables here. Examples:
export (Vector2) var heal_coords = Vector2(0,0);
export (Color) var color = Color.red
export (float) var health = 100;
export (String) var machine_name = "Z";
export (Vector2) var direction = Vector2(0,0)
export var MAX_HEALTH : int = 100
export var HEALTHY_MIN_PCT : int = 90
export var DAMAGE_MIN_PCT : int = 50
onready var healthNode : Sprite = find_node("health")
onready var lightNode : Sprite = find_node("light")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Dashboard").connect("machine_health", self, "_on_machine_health")
	get_node("/root/Dashboard").connect("repair_machine", self, "_on_repair_machine")

	if healthNode:
		if healthNode["IS_HEALTHY"]:
			healthNode["IS_HEALTHY"] = HEALTHY_MIN_PCT
		if healthNode["IS_DAMAGED"]:
			healthNode["IS_DAMAGED"] = DAMAGE_MIN_PCT
		healthNode.get_child(1).text = self.machine_name
	#var p = Vector2(self.global_position.x+self.texture.get_width(), self.global_position.y-self.texture.get_height())

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	if machineIdx == self.key:
		healthNode.repair = true

func _on_machine_health(data):
	#print(self.name, data)
	if data.id == self.name:
		health = data.percent if data.has('percent') else data.value
