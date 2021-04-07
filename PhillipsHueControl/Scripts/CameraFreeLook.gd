# Copyright © 2017 Hugo Locurcio and contributors - MIT license
# Copyright © 2019 Manuel 'TheDuriel' Fischer - MIT license
# https://gist.github.com/Calinou/820ca6211eef32f531d26e89c4262de9

extends Spatial
class_name FreeLook

const MOVE_SPEED: float = .5
const MOUSE_SENSITIVITY: float = 0.002

onready var speed: int = 1
onready var velocity: Vector3 = Vector3()
onready var initial_rotation: float = TAU / 4

func _ready() -> void:
	# Capture the mouse (can be toggled by pressing 1)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	
	pass


func _input(event) -> void:
	# Horizontal mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x*MOUSE_SENSITIVITY
	
	# Vertical mouse look, clamped to -90..90 degrees
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation.x = clamp(rotation.x - event.relative.y*MOUSE_SENSITIVITY, deg2rad(-90), deg2rad(90))
	
	# Toggle mouse capture
	if event is InputEventKey and event.scancode == KEY_ESCAPE and not event.is_echo() and event.pressed:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	# Speed modifier
	if Input.is_key_pressed(KEY_SHIFT):
		speed = 2
	else:
		speed = 1
	
	# Movement
	if Input.is_key_pressed(KEY_W):
		velocity.x -= MOVE_SPEED*speed*delta
	if Input.is_key_pressed(KEY_S):
		velocity.x += MOVE_SPEED*speed*delta
	if Input.is_key_pressed(KEY_A):
		velocity.z += MOVE_SPEED*speed*delta
	if Input.is_key_pressed(KEY_D):
		velocity.z -= MOVE_SPEED*speed*delta
	
	if Input.is_key_pressed(KEY_E):
		velocity.y += MOVE_SPEED*speed*delta
	if Input.is_key_pressed(KEY_Q):
		velocity.y -= MOVE_SPEED*speed*delta
	
	# Friction
	velocity *= 0.875
	
	# Apply velocity
	translation += velocity \
	.rotated(Vector3(0, 1, 0), rotation.y - initial_rotation) \
	.rotated(Vector3(1, 0, 0), cos(rotation.y)*rotation.x) \
	.rotated(Vector3(0, 0, 1), -sin(rotation.y)*rotation.x)


func _exit_tree() -> void:
	# Restore the mouse cursor upon quitting
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
