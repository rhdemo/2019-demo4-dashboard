extends Node2D

export var wp_number = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$number.text = String(wp_number)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
