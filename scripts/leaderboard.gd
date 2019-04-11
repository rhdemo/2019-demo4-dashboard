extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$toDashboard/load_dashboard.connect("pressed", self, "load_dashboard")
	
func load_dashboard():
	get_tree().change_scene("res://iso_factory.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
