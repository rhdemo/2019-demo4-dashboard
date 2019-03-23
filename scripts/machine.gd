extends Sprite

# Declare member variables here. Examples:
export (int) var healX = 0;
export (int) var healY = 0;
export (float) var health = 1;
export (String) var machine_name = "A"
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$health.text = machine_name
	#var p = Vector2(self.global_position.x+self.texture.get_width(), self.global_position.y-self.texture.get_height())
	var p = Vector2(500,-200)
	$health.set_position(p)	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
