extends Node

signal move_direction_changed(direction: Vector2)
signal interact_pressed()
signal crouch_pressed()
signal crouch_released()
signal pause_pressed()
signal tap_move(position: Vector2)

var _move_input: Vector2 = Vector2.ZERO
var _is_crouching: bool = false
var _use_tap_move: bool = false
var _last_tap_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(_delta: float) -> void:
	_process_movement_input()
	_process_action_inputs()
	_process_tap_move()

func _process_movement_input() -> void:
	var move_input = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		move_input.x -= 1
	if Input.is_action_pressed("move_right"):
		move_input.x += 1
	if Input.is_action_pressed("move_up"):
		move_input.y -= 1
	if Input.is_action_pressed("move_down"):
		move_input.y += 1
	
	move_input = move_input.normalized() if move_input.length() > 0 else Vector2.ZERO
	
	if move_input != _move_input:
		_move_input = move_input
		move_direction_changed.emit(_move_input)

func _process_action_inputs() -> void:
	if Input.is_action_just_pressed("interact"):
		interact_pressed.emit()
	
	if Input.is_action_just_pressed("crouch"):
		_is_crouching = true
		crouch_pressed.emit()
	elif Input.is_action_just_released("crouch"):
		_is_crouching = false
		crouch_released.emit()
	
	if Input.is_action_just_pressed("pause"):
		pause_pressed.emit()

func _process_tap_move() -> void:
	if not _use_tap_move:
		return
	
	if Input.is_action_just_pressed("tap_move"):
		var viewport = get_viewport()
		var touch_position = viewport.get_mouse_position()
		_last_tap_position = touch_position
		tap_move.emit(touch_position)

func get_move_direction() -> Vector2:
	return _move_input

func is_crouching() -> bool:
	return _is_crouching

func set_use_tap_move(enabled: bool) -> void:
	_use_tap_move = enabled

func is_using_tap_move() -> bool:
	return _use_tap_move

func get_last_tap_position() -> Vector2:
	return _last_tap_position

func set_mouse_mode(mode: int) -> void:
	Input.mouse_mode = mode