extends CenterContainer

onready var healthyTexture = preload("res://sprites/health/health-green.png")
onready var damagedTexture = preload("res://sprites/health/health-orange.png")
onready var brokenTexture = preload("res://sprites/health/health-red.png")
onready var repairBGTexture = preload("res://sprites/health/health-maintenance-icon.png")
onready var healthBGTexture = preload("res://sprites/health/health-bg.png")

signal machine_damaged
signal machine_repaired
export var IS_HEALTHY : int = 70
export var IS_DAMAGED : int = 30
export (Texture) var icon

export (bool) var repair = false
export (float) var health = 100.0;
export (Vector2) var originalPosition

func _init():
	pass
func _ready():
	originalPosition = rect_position
	
func _process(delta):
	if !repair:
		$value.texture_over = icon
	else:
		$value.texture_over = repairBGTexture
	if health >= IS_HEALTHY:
		$value.texture_progress = healthyTexture
	elif health > IS_DAMAGED:
		$value.texture_progress = damagedTexture
	else:
		$value.texture_progress = brokenTexture
	$value.value = health