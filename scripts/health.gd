extends Area2D

onready var healthyTexture = preload("res://sprites/machines/health-green.png")
onready var damagedTexture = preload("res://sprites/machines/health-orange.png")
onready var brokenTexture = preload("res://sprites/machines/health-red.png")

signal machine_damaged
signal machine_repaired
const IS_HEALTHY = 90
const IS_DAMAGED = 50

export (float) var health = 100.0;
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	if health >= IS_HEALTHY:
		$value.texture_progress = healthyTexture
	elif health > IS_DAMAGED:
		$value.texture_progress = damagedTexture
	else:
		$value.texture_progress = brokenTexture
	$value.value = health

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass