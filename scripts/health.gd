extends Sprite

onready var healthyTexture = preload("res://sprites/health/health-green.png")
onready var damagedTexture = preload("res://sprites/health/health-orange.png")
onready var brokenTexture = preload("res://sprites/health/health-red.png")
onready var repairTexture = preload("res://sprites/health/health-maintenance-icon.png")

signal machine_damaged
signal machine_repaired
export var IS_HEALTHY : int = 90
export var IS_DAMAGED : int = 50

export (bool) var repair = false
export (float) var health = 100.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	if repair:
		$value.texture_over = repairTexture
	elif health >= IS_HEALTHY:
		$value.texture_progress = healthyTexture
	elif health > IS_DAMAGED:
		$value.texture_progress = damagedTexture
	else:
		$value.texture_progress = brokenTexture
	$value.value = health