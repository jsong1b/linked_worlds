extends CharacterBody3D

@export var speed: float = 0.0
@export var instant_speed: float = 7.5
@export var local_velocity: Vector2 = Vector2(0.0, 0.0)

@export var ground_accel: float = 2.0
@export var ground_decel: float = 0.15
@export var max_ground_speed: float = 15.0

@export var air_accel: float = 3.0
@export var air_decel: float = 0.005

@export var sliding: bool = false
@export var instant_slide_speed: float = 5.0
@export var slide_ground_decel: float = 0.010

@export var instant_jump_upward_speed: float = 5.0
@export var player_gravity: float = 15.0


@export var prev_direction: Vector2 = Vector2(0, 0);
func _physics_process(delta: float) -> void:
	velocity.y -= player_gravity * delta

	if Input.is_action_just_pressed("jump"):
		if is_on_floor(): velocity.y += instant_jump_upward_speed

	var accel = ground_accel
	var decel = ground_decel
	if not is_on_floor():
		accel = air_accel
		decel = air_decel

	var direction = Input.get_vector("left", "right", "forward", "back")
	print("=================")
	print(velocity)
	if direction.x == 0: local_velocity.x = lerp(local_velocity.x, 0.0, decel)
	if direction.y == 0: local_velocity.y = lerp(local_velocity.y, 0.0, decel)

	if direction:
		if local_velocity.x > max_ground_speed and is_on_floor(): local_velocity.x = lerp(local_velocity.x, max_ground_speed, decel)
		elif local_velocity.x < -max_ground_speed and is_on_floor(): local_velocity.x = lerp(local_velocity.x, -max_ground_speed, decel)
		elif prev_direction.x == 0: local_velocity.x = direction.x * instant_speed
		else: local_velocity.x += direction.x * accel * delta

		if local_velocity.y > max_ground_speed and is_on_floor(): local_velocity.y = lerp(local_velocity.y, max_ground_speed, decel)
		elif local_velocity.y < -max_ground_speed and is_on_floor(): local_velocity.y = lerp(local_velocity.y, -max_ground_speed, decel)
		elif prev_direction.y == 0: local_velocity.y = direction.y * instant_speed
		else: local_velocity.y += direction.y * accel * delta
	velocity = transform.basis * Vector3(local_velocity.x, velocity.y, local_velocity.y)
	prev_direction = Vector2(direction.x, direction.y)


	if Input.is_action_pressed("click"):
		if not sliding:
			sliding = true
		else:
			pass
	else: sliding = false
	print("sliding:", sliding)


	move_and_slide()


@export var mouse_sensitivity = 0.002
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -1.2, 1.2)
