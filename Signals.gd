extends Node

signal test_signal

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _test_signal():
	emit_signal("test_signal")

func emit(name):
	emit_signal(name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
