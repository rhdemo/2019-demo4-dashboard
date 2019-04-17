extends KinematicBody2D

const ACCEL = 1500
const MAX_SPEED = 20
const FRICTION = -500
const GRAVITY = 500

var acc = Vector2()
var vel = Vector2(0,200)
var dropping = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var collision = move_and_collide(vel * delta)
	if collision:
		if collision.collider.name == "mover":
			vel = vel.slide(collision.normal)
		elif collision.collider.name == "disposal":
			get_parent().remove_child(self)
			queue_free()
		else:
			vel = Vector2(0,150)