extends KinematicBody2D

const ACCEL = 1500
const MAX_SPEED = 20
const FRICTION = -500
const GRAVITY = 500

var acc = Vector2()
var vel = Vector2(10,100)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _fixed_process(delta):
func _physics_process(delta):
	var collision = move_and_collide(vel * delta)
	if collision:
		if collision.collider.name != "deflector":
			vel = vel.slide(collision.normal)
		if collision.collider.name == "disposal":
			get_parent().remove_child(self)
			queue_free()
	else:
		vel = Vector2(25,150)