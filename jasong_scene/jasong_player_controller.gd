extends CharacterBody3D

@export var speed: float = 0.0
@export var instant_speed: float = 7.5
@export var local_velocity: Vector2 = Vector2(0.0, 0.0)

@export var ground_accel: float = 1.25
@export var ground_decel: float = 0.15
@export var max_ground_speed: float = 15.0

@export var air_accel: float = 1.75
@export var air_decel: float = 0.075

@export var can_slide: bool = true
@export var sliding: bool = false
@export var instant_ground_slide_speed_mod: float = 1.05
@export var instant_slide_jump_speed_mod: float = 1.075
@export var slide_ground_decel: float = 0.0075

@export var can_jump: bool = false
@export var jumping: bool = false
@export var instant_jump_upward_speed: float = 5.0
@export var player_gravity: float = 15.0

@export var wall_jump_vel: Vector3 = Vector3(0.0, 0.0, 0.0)
@export var wall_running: bool = false
@export var wall_run_down_velocity: float = 1.0
@export var instant_wall_run_jump_upward_speed: float = 7.5


@export var prev_direction: Vector2 = Vector2(0, 0);
func _physics_process(delta: float) -> void:
	if position.y <= -50:
		position.x = 0
		position.y = 0
		position.z = 0
	if is_on_floor():
		can_jump = true
		jumping = false

	# wall running
	if not is_on_floor() and is_on_wall(): wall_running = true
	else: wall_running = false
	if not wall_running: velocity.y -= player_gravity * delta
	else: velocity.y = -wall_run_down_velocity

	# sliding
	if sliding:
		$"Capsule Collision".position.y = lerp($"Capsule Collision".position.y, 0.5, 0.1)
		$"Capsule Collision".scale.y = lerp($"Capsule Collision".scale.y, 0.5, 0.1)
		$Camera3D.position.y = lerp($"Camera3D".position.y, 0.5, 0.1)
	else:
		$"Capsule Collision".position.y = lerp($"Capsule Collision".position.y, 1.0, 0.1)
		$"Capsule Collision".scale.y = lerp($"Capsule Collision".scale.y, 1.0, 0.1)
		$Camera3D.position.y = lerp($"Camera3D".position.y, 1.6, 0.1)

	# accel / decel
	var accel = ground_accel
	var decel = ground_decel
	if sliding:
		decel = slide_ground_decel
	if not is_on_floor():
		accel = air_accel
		decel = air_decel
	if wall_running: decel = ground_decel

	# direction + applying velocity
	var direction = Input.get_vector("left", "right", "forward", "back")
	print(wall_jump_vel)
	wall_jump_vel.x = lerp(wall_jump_vel.x, 0.0, 0.1)
	wall_jump_vel.y = lerp(wall_jump_vel.y, 0.0, 0.75)
	wall_jump_vel.z = lerp(wall_jump_vel.z, 0.0, 0.1)
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
	prev_direction = Vector2(direction.x, direction.y)

	# jumping
	if Input.is_action_just_pressed("jump"):
		if can_jump or is_on_floor() or wall_running:
			jumping = true
			can_jump = false
			if not wall_running: velocity.y += instant_jump_upward_speed
			else:
				wall_jump_vel.y += instant_wall_run_jump_upward_speed
				wall_jump_vel += get_wall_normal() * 10
			if sliding: local_velocity *= instant_slide_jump_speed_mod
			$"Coyote Timer".start()

	# sliding input
	if Input.is_action_pressed("click"):
		if not sliding and can_slide:
			sliding = true
			if is_on_floor(): local_velocity *= instant_ground_slide_speed_mod

			can_slide = false
			$"Slide Timeout".start()
	else: sliding = false

	# apply velocity + move
	velocity = (transform.basis * Vector3(local_velocity.x, velocity.y, local_velocity.y)) + wall_jump_vel
	move_and_slide()


@export var mouse_sensitivity = 0.002
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -1.2, 1.2)


func _on_slide_timeout_timeout() -> void:
	can_slide = true
	sliding = false


func _on_coyote_timer_timeout() -> void: can_jump = false
