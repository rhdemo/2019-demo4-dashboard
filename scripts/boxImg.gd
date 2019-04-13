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
	if pos < .025:
		hide()
	elif pos > .041 and pos < .075:
		hide()
	elif pos > .27 and pos < .35:
		hide()
	elif pos > .398 and pos < .43:
		hide()
	else:
		show()