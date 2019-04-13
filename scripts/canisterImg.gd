extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true) # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pos = get_parent().unit_offset
	if pos > .15 and pos < .355:
		frame = 1
	elif pos > .355:
		hide()
	else:
		frame = 0
		show()
		
	
