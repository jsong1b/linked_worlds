extends CharacterBody3D
class_name FPSPlayer

signal hit

@export var speed = 7.0
@export var jump_speed = 8.0
@export var mouse_sensitivity = 0.002

var coyote_frames = 10
var coyote = false
var last_floor = false
var jumping = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$CoyoteTimer.wait_time = coyote_frames / 60.0
	
func _unhandled_input(event):
	if event.is_action_pressed("click"):
		print("shoot")
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -1.2, 1.2)

func get_move_input():
	var input = Input.get_vector("left", "right", "forward", "back")
	var dir = transform.basis * Vector3(input.x, 0, input.y)
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	
func _physics_process(delta):
	velocity.y += -gravity * delta
	get_move_input()
	
	move_and_slide()
	if is_on_floor() and jumping:
		jumping = false
	if !is_on_floor() and last_floor and !jumping:
		coyote = true
		$CoyoteTimer.start()
#		print("coyote start")
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote):
		velocity.y = jump_speed
		jumping = true
		
	last_floor = is_on_floor()
	if position.y < -3:
		get_tree().reload_current_scene()
	
	if $RayCast3D.is_colliding():
		var floor = $RayCast3D.get_collider()
		if floor.get_parent().has_method("fall"):
			floor.get_parent().fall()
	
func _on_coyote_timer_timeout():
	coyote = false
#	print("coyote end")

func damage():
	print("hit")
	hit.emit()
