extends Node3D

@export var target_path: NodePath
@export var follow_speed := 8.0
@export var lag_amount := 0.12
@export var vertical_lag_scale := 0.35
@export var snap_distance := 9.0
@export var snap_on_ready := true
@export var camera_distance := 18.0
@export var camera_height := 5.0
@export var camera_pitch_degrees := -15.0
@export var field_of_view := 48.0

@onready var spring_arm: SpringArm3D = %SpringArm3D
@onready var camera: Camera3D = %Camera3D

var _target: Node3D
var _previous_target_position := Vector3.ZERO


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_configure_camera()

	if _target == null:
		return

	_previous_target_position = _target.global_position
	if snap_on_ready:
		_snap_to_target()


func _physics_process(delta: float) -> void:
	if _target == null:
		return

	var target_position := _target.global_position
	var target_velocity := (target_position - _previous_target_position) / maxf(delta, 0.001)
	_previous_target_position = target_position

	var desired_position := _get_desired_position(target_position, target_velocity)
	if global_position.distance_to(desired_position) > snap_distance:
		global_position = desired_position
		return

	var blend := 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(desired_position, blend)


func snap_to_target() -> void:
	if _target == null:
		return

	_snap_to_target()


func _snap_to_target() -> void:
	global_position = _get_desired_position(_target.global_position, Vector3.ZERO)


func _get_desired_position(target_position: Vector3, target_velocity: Vector3) -> Vector3:
	var lag_offset := Vector3(
		-target_velocity.x * lag_amount,
		-target_velocity.y * lag_amount * vertical_lag_scale,
		0.0
	)
	return Vector3(target_position.x, target_position.y, 0.0) + lag_offset


func _configure_camera() -> void:
	spring_arm.position = Vector3(0.0, camera_height, 0.0)
	spring_arm.rotation_degrees = Vector3(camera_pitch_degrees, 0.0, 0.0)
	spring_arm.spring_length = camera_distance
	camera.position = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	camera.fov = field_of_view
	camera.current = true
