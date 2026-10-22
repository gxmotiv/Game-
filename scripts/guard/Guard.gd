extends CharacterBody2D

class_name Guard

enum PatrolMode { LOOP, PING_PONG, RANDOM, STATIONARY }

@export var patrol_mode: PatrolMode = PatrolMode.LOOP
@export var move_speed: float = 120.0
@export var turn_speed: float = 3.0
@export var waypoints: Array[Vector2] = []
@export var pause_at_waypoint: float = 1.5
@export var fov_angle: float = 90.0
@export var fov_range: float = 200.0
@export var detection_buildup_rate: float = 30.0
@export var detection_decay_rate: float = 15.0
@export var detection_threshold: float = 100.0

signal player_detected(player: Node)
signal player_lost(player: Node)
signal detection_changed(level: float)
signal patrol_state_changed(state: String)

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _vision_cone: Polygon2D = $VisionCone
@onready var _vision_area: Area2D = $VisionArea
@onready var _collision: CollisionShape2D = $CollisionShape2D

var _current_waypoint_index: int = 0
var _patrol_direction: int = 1
var _state: String = "patrol"
var _pause_timer: float = 0.0
var _detection_level: float = 0.0
var _target_player: Node = null
var _last_known_player_pos: Vector2 = Vector2.ZERO
var _raycast: RayCast2D
var _path: NavigationAgent2D

func _ready() -> void:
	_raycast = RayCast2D.new()
	_raycast.collision_mask = 4
	add_child(_raycast)
	
	_path = NavigationAgent2D.new()
	add_child(_path)
	
	_vision_area.body_entered.connect(_on_vision_body_entered)
	_vision_area.body_exited.connect(_on_vision_body_exited)
	
	_update_vision_cone()
	_set_state("patrol")
	
	if waypoints.size() > 0:
		global_position = waypoints[0]

func _physics_process(delta: float) -> void:
	if GameManager.get_game_state() != GameManager.GameState.PLAYING:
		velocity = Vector2.ZERO
		return
	
	_update_detection(delta)
	
	match _state:
		"patrol":
			_do_patrol(delta)
		"investigate":
			_do_investigate(delta)
		"chase":
			_do_chase(delta)
		"return":
			_do_return(delta)

func _update_detection(delta: float) -> void:
	if _target_player and is_instance_valid(_target_player):
		var can_see = _check_line_of_sight(_target_player.global_position)
		if can_see:
			_detection_level = min(_detection_level + detection_buildup_rate * delta, detection_threshold)
		else:
			_detection_level = max(_detection_level - detection_decay_rate * delta, 0.0)
	else:
		_detection_level = max(_detection_level - detection_decay_rate * delta, 0.0)
	
	detection_changed.emit(_detection_level)
	_vision_cone.modulate = Color(1.0, 1.0 - _detection_level / detection_threshold, 1.0 - _detection_level / detection_threshold, 0.3)
	
	if _detection_level >= detection_threshold and _state != "chase":
		_set_state("chase")
		player_detected.emit(_target_player)

func _check_line_of_sight(target_pos: Vector2) -> bool:
	var direction = (target_pos - global_position).normalized()
	var distance = global_position.distance_to(target_pos)
	
	if distance > fov_range:
		return false
	
	var angle_to_target = direction.angle()
	var guard_facing = _get_facing_direction().angle()
	var angle_diff = abs(angle_to_target - guard_facing)
	angle_diff = fmod(angle_diff + PI, TAU) - PI
	angle_diff = abs(angle_diff)
	
	if angle_diff > deg_to_rad(fov_angle / 2.0):
		return false
	
	_raycast.global_position = global_position
	_raycast.target_position = target_pos
	_raycast.force_raycast_update()
	
	if _raycast.is_colliding():
		var collider = _raycast.get_collider()
		if collider == _target_player:
			return true
		if collider.is_in_group("wall"):
			return false
	
	return true

func _get_facing_direction() -> Vector2:
	if velocity.length() > 1:
		return velocity.normalized()
	return Vector2.RIGHT

func _do_patrol(delta: float) -> void:
	if waypoints.is_empty():
		return
	
	if _pause_timer > 0:
		_pause_timer -= delta
		velocity = Vector2.ZERO
		return
	
	var target = waypoints[_current_waypoint_index]
	var direction = (target - global_position).normalized()
	var distance = global_position.distance_to(target)
	
	if distance < 10.0:
		_pause_timer = pause_at_waypoint
		_advance_waypoint()
	else:
		velocity = velocity.lerp(direction * move_speed, turn_speed * delta)
	
	move_and_slide()

func _advance_waypoint() -> void:
	match patrol_mode:
		PatrolMode.LOOP:
			_current_waypoint_index = (_current_waypoint_index + 1) % waypoints.size()
		PatrolMode.PING_PONG:
			_current_waypoint_index += _patrol_direction
			if _current_waypoint_index >= waypoints.size() - 1:
				_current_waypoint_index = waypoints.size() - 2
				_patrol_direction = -1
			elif _current_waypoint_index <= 0:
				_current_waypoint_index = 1
				_patrol_direction = 1
		PatrolMode.RANDOM:
			_current_waypoint_index = randi() % waypoints.size()
		PatrolMode.STATIONARY:
			pass

func _do_investigate(delta: float) -> void:
	var direction = (_last_known_player_pos - global_position).normalized()
	var distance = global_position.distance_to(_last_known_player_pos)
	
	if distance < 20.0:
		_set_state("return")
		return
	
	velocity = velocity.lerp(direction * move_speed * 1.2, turn_speed * delta)
	move_and_slide()

func _do_chase(delta: float) -> void:
	if not _target_player or not is_instance_valid(_target_player):
		_set_state("return")
		return
	
	_last_known_player_pos = _target_player.global_position
	
	var direction = (_target_player.global_position - global_position).normalized()
	var distance = global_position.distance_to(_target_player.global_position)
	
	if distance > fov_range * 1.5 or not _check_line_of_sight(_target_player.global_position):
		_set_state("investigate")
		return
	
	velocity = velocity.lerp(direction * move_speed * 1.5, turn_speed * delta)
	move_and_slide()

func _do_return(delta: float) -> void:
	if waypoints.is_empty():
		_set_state("patrol")
		return
	
	var target = waypoints[_current_waypoint_index]
	var direction = (target - global_position).normalized()
	var distance = global_position.distance_to(target)
	
	if distance < 10.0:
		_set_state("patrol")
		return
	
	velocity = velocity.lerp(direction * move_speed, turn_speed * delta)
	move_and_slide()

func _set_state(new_state: String) -> void:
	if _state == new_state:
		return
	
	_state = new_state
	patrol_state_changed.emit(new_state)
	
	match new_state:
		"patrol":
			_sprite.play("patrol")
		"investigate":
			_sprite.play("investigate")
		"chase":
			_sprite.play("chase")
		"return":
			_sprite.play("patrol")

func _update_vision_cone() -> void:
	var points = [Vector2.ZERO]
	var half_angle = deg_to_rad(fov_angle / 2.0)
	var steps = 16
	
	for i in range(steps + 1):
		var angle = -half_angle + (half_angle * 2.0 * i / steps)
		var point = Vector2(cos(angle), sin(angle)) * fov_range
		points.append(point)
	
	_vision_cone.polygon = points
	
	var collision_poly = CollisionPolygon2D.new()
	collision_poly.polygon = points
	_vision_area.remove_child(_vision_area.get_node_or_null("VisionCollision"))
	collision_poly.name = "VisionCollision"
	_vision_area.add_child(collision_poly)

func _on_vision_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_target_player = body
		_last_known_player_pos = body.global_position

func _on_vision_body_exited(body: Node) -> void:
	if body == _target_player:
		_target_player = null

func get_detection_level() -> float:
	return _detection_level

func get_state() -> String:
	return _state

func set_waypoints(new_waypoints: Array[Vector2]) -> void:
	waypoints = new_waypoints
	if waypoints.size() > 0:
		_current_waypoint_index = 0