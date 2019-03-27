extends Sprite

# Declare member variables here. Examples:
export (Vector2) var healthbar_location = Vector2(0,0);
export (Vector2) var heal_tile = Vector2(0,0);
export (Vector2) var light_location = Vector2(0, 0);
export (float) var health = 1.0;
export (String) var machine_name = "0";
export (Texture) var tex;
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$health.connect("machine_damaged", self, "_on_health_machine_damaged")
	self.texture = tex

	$health/icon/label.text = self.machine_name
	if self.texture:
		#$graphic.set_position()
		$light.set_position(self.light_location)
		$health.set_position(self.healthbar_location)
		#$collision.
	#var p = Vector2(self.global_position.x+self.texture.get_width(), self.global_position.y-self.texture.get_height())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$health.health = self.health
	#print(machine_name, " HEALTH:", $health.health)

func _on_health_machine_damaged(data):
	print(machine_name," clicked:", self.health)
	if $light/anim.current_animation == 'alert':
		$light/anim.play("healthy")
	else:
		$light/anim.play("alert")


func _on_health_machine_repaired(data):
	print(data)