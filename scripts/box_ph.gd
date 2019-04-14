extends KinematicBody2D

const ACCEL = 1500
const MAX_SPEED = 20
const FRICTION = -500
const GRAVITY = 2000

var acc = Vector2()
var vel = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _fixed_process(delta):
func _physics_process(delta):
	acc.x = 0
	acc.y = GRAVITY
	vel += acc * delta
	#vel.x = clamp(vel.x, -MAX_SPEED, MAX_SPEED)
	move_and_slide(vel, Vector2(0,0), true, 4, 1.5708, true) 
