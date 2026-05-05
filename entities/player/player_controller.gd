extends CharacterBody3D

@export var max_speed := 8.0
@export var acceleration := 48.0
@export var deceleration := 56.0
@export var jump_velocity := 12.0
@export var gravity := 32.0
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12
@export var dash_speed := 18.0
@export var dash_duration := 0.14
@export var dash_cooldown := 0.28

@onready var visual: Node3D = %Visual

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _dash_timer := 0.0
var _dash_cooldown_timer := 0.0
var _dash_direction := 1.0
var _facing := 1.0


func _physics_process(delta: float) -> void:
	var input_direction := Input.get_axis("move_left", "move_right")
	if not is_zero_approx(input_direction):
		_facing = signf(input_direction)

	_update_timers(delta)
	_buffer_jump()

	if _dash_timer > 0.0:
		_apply_dash(delta)
	else:
		_apply_horizontal_movement(input_direction, delta)
		_apply_gravity(delta)
		_try_jump()
		_try_dash(input_direction)

	velocity.z = 0.0
	move_and_slide()
	global_position.z = 0.0
	_update_visual(delta)


func _update_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)
	_dash_timer = maxf(_dash_timer - delta, 0.0)
	_dash_cooldown_timer = maxf(_dash_cooldown_timer - delta, 0.0)


func _buffer_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time


func _apply_horizontal_movement(input_direction: float, delta: float) -> void:
	var target_speed := input_direction * max_speed
	var rate := acceleration if not is_zero_approx(input_direction) else deceleration
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0


func _try_jump() -> void:
	if _jump_buffer_timer <= 0.0 or _coyote_timer <= 0.0:
		return

	velocity.y = jump_velocity
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0


func _try_dash(input_direction: float) -> void:
	if not Input.is_action_just_pressed("dash") or _dash_cooldown_timer > 0.0:
		return

	_dash_direction = signf(input_direction) if not is_zero_approx(input_direction) else _facing
	_dash_timer = dash_duration
	_dash_cooldown_timer = dash_cooldown
	velocity = Vector3(_dash_direction * dash_speed, 0.0, 0.0)


func _apply_dash(_delta: float) -> void:
	velocity.x = _dash_direction * dash_speed
	velocity.y = 0.0


func _update_visual(delta: float) -> void:
	if not visual:
		return
	
	var speed_ratio := clampf(absf(velocity.x) / max_speed, 0.0, 1.0)
	var target_scale := Vector3(1.0 + speed_ratio * 0.12, 1.0 - speed_ratio * 0.08, 1.0)

	if not is_on_floor():
		target_scale = Vector3(0.92, 1.12, 1.0)
	if _dash_timer > 0.0:
		target_scale = Vector3(1.28, 0.72, 1.0)

	visual.scale = visual.scale.lerp(target_scale, 18.0 * delta)
