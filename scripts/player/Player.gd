extends CharacterBody2D

class_name Player

@export var move_speed: float = 180.0
@export var crouch_speed_multiplier: float = 0.5
@export var acceleration: float = 20.0

signal detected_by_guard(guard: Node)
signal interacted_with(object: Node)

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _detection_meter: ProgressBar = $DetectionMeter

var _input_direction: Vector2 = Vector2.ZERO
var _is_crouching: bool = false
var _target_position: Vector2 = Vector2.ZERO
var _use_tap_move: bool = false
var _tap_move_active: bool = false
var _interactable_in_range: Array[Node] = []

func _ready() -> void:
	InputManager.move_direction_changed.connect(_on_move_direction_changed)
	InputManager.interact_pressed.connect(_on_interact_pressed)
	InputManager.crouch_pressed.connect(_on_crouch_pressed)
	InputManager.crouch_released.connect(_on_crouch_released)
	InputManager.tap_move.connect(_on_tap_move)
	GameManager.settings_changed.connect(_on_settings_changed)
	
	_on_settings_changed(GameManager.get_settings())
	
	_sprite.play("idle")
	_detection_meter.visible = false
	_detection_meter.max_value = 100.0
	_detection_meter.value = 0.0

func _physics_process(delta: float) -> void:
	if GameManager.get_game_state() != GameManager.GameState.PLAYING:
		velocity = Vector2.ZERO
		return
	
	var current_speed = move_speed * (_is_crouching ? crouch_speed_multiplier : 1.0)
	
	if _use_tap_move and _tap_move_active:
		var direction = (_target_position - global_position).normalized()
		var distance = global_position.distance_to(_target_position)
		
		if distance > 5.0:
			velocity = velocity.lerp(direction * current_speed, acceleration * delta)
			_input_direction = direction
		else:
			velocity = Vector2.ZERO
			_tap_move_active = false
			_input_direction = Vector2.ZERO
	else:
		velocity = velocity.lerp(_input_direction * current_speed, acceleration * delta)
	
	move_and_slide()
	_update_animation()

func _update_animation() -> void:
	if velocity.length() > 10:
		if _is_crouching:
			_sprite.play("crouch_walk")
		else:
			_sprite.play("walk")
	else:
		if _is_crouching:
			_sprite.play("crouch_idle")
		else:
			_sprite.play("idle")
	
	if velocity.x != 0:
		_sprite.flip_h = velocity.x < 0

func _on_move_direction_changed(direction: Vector2) -> void:
	if not _use_tap_move:
		_input_direction = direction

func _on_interact_pressed() -> void:
	for obj in _interactable_in_range:
		if is_instance_valid(obj):
			interacted_with.emit(obj)
			break

func _on_crouch_pressed() -> void:
	_is_crouching = true

func _on_crouch_released() -> void:
	_is_crouching = false

func _on_tap_move(position: Vector2) -> void:
	if _use_tap_move:
		_target_position = position
		_tap_move_active = true

func _on_settings_changed(settings: Dictionary) -> void:
	_use_tap_move = settings.get("use_tap_move", false)
	_detection_meter.visible = settings.get("show_detection_meter", true)

func set_detection_level(level: float) -> void:
	_detection_meter.value = clamp(level, 0.0, 100.0)

func get_is_crouching() -> bool:
	return _is_crouching

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("interactable"):
		_interactable_in_range.append(body)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("interactable"):
		_interactable_in_range.erase(body)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("guard_vision"):
		var guard = area.get_parent()
		if guard and guard.has_method("on_player_detected"):
			detected_by_guard.emit(guard)