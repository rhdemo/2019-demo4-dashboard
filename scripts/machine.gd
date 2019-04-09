extends Sprite

# Declare member variables here. Examples:
export (Vector2) var healthbar_location = Vector2(0,0);
export (Vector2) var heal_tile = Vector2(0,0);
export (Vector2) var light_location = Vector2(0, 0);
export (float) var health = 1.0;
export (String) var machine_name = "0";
export (Texture) var tex;
# var b = "text"

signal dispatch_mechanic

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect("machine_health", self, "_on_machine_health")
	self.texture = tex

	$health/label.text = self.machine_name
	if self.texture:
		#$graphic.set_position()
		$light.set_position(self.light_location)
		$health.set_position(self.healthbar_location)
		#$collision.
	#var p = Vector2(self.global_position.x+self.texture.get_width(), self.global_position.y-self.texture.get_height())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health < 934318851427100800:
		$light/anim.play("alert")
	else:
		$light/anim.current_animation == 'alert'
		$light/anim.play("healthy")
	$health.health = self.health	
	
	#$light.set_position(self.light_location)
	#$health.set_position(self.healthbar_location)
	#print(machine_name, " HEALTH:", $health.health)

func _on_machine_health(data):
	#print(self.name, data)
	if data.id == self.name:
		health = data.value


func _on_health_machine_repaired(data):
	print(data)