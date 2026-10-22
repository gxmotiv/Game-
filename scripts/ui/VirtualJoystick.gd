extends Control

class_name VirtualJoystick

signal direction_changed(direction: Vector2)

@export var radius: float = 80.0
@export var deadzone: float = 0.2

var _center: Vector2 = Vector2.ZERO
var _knob_position: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _touch_id: int = -1

@onready var _background: TextureRect = $Background
@onready var _knob: TextureRect = $Knob

func _ready() -> void:
	_background.size = Vector2(radius * 2, radius * 2)
	_knob.size = Vector2(radius, radius)
	
	_background.texture = _create_circle_texture(radius * 2, Color(0.3, 0.3, 0.3, 0.5))
	_knob.texture = _create_circle_texture(radius, Color(0.6, 0.6, 0.6, 0.7))
	
	_visible = false
	_background.hide()
	_knob.hide()

func _create_circle_texture(size: float, color: Color) -> ImageTexture:
	var img = Image.create(int(size), int(size), false, Image.FORMAT_RGBA8)
	var center = Vector2(size / 2.0, size / 2.0)
	var r = size / 2.0
	
	for x in range(int(size)):
		for y in range(int(size)):
			var dist = Vector2(x + 0.5, y + 0.5).distance_to(center)
			if dist <= r:
				var alpha = color.a * (1.0 - dist / r * 0.3)
				img.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	
	var texture = ImageTexture.create_from_image(img)
	return texture

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	var local_pos = to_local(event.position)
	
	if event.pressed:
		if _background.get_rect().has_point(local_pos):
			_dragging = true
			_touch_id = event.index
			_center = local_pos
			_background.global_position = event.position - Vector2(radius, radius)
			_knob.global_position = event.position - Vector2(radius / 2, radius / 2)
			_visible = true
			_show_joystick()
	else:
		if event.index == _touch_id:
			_dragging = false
			_touch_id = -1
			_hide_joystick()
			direction_changed.emit(Vector2.ZERO)

func _handle_drag(event: InputEventScreenDrag) -> void:
	if not _dragging or event.index != _touch_id:
		return
	
	var local_pos = to_local(event.position)
	var diff = local_pos - _center
	var distance = diff.length()
	
	if distance > radius:
		diff = diff.normalized() * radius
	
	_knob_position = diff
	_knob.global_position = event.position - Vector2(radius / 2, radius / 2)
	
	var direction = _knob_position / radius
	if direction.length() < deadzone:
		direction = Vector2.ZERO
	
	direction_changed.emit(direction)

func _show_joystick() -> void:
	_background.show()
	_knob.show()
	_background.modulate = Color(1, 1, 1, 1.0)
	_knob.modulate = Color(1, 1, 1, 1.0)

func _hide_joystick() -> void:
	var tween = create_tween()
	tween.tween_property(_background, "modulate:a", 0.0, 0.2)
	tween.tween_property(_knob, "modulate:a", 0.0, 0.2)
	tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished() -> void:
	if not _dragging:
		_background.hide()
		_knob.hide()
		_background.modulate = Color(1, 1, 1, 1.0)
		_knob.modulate = Color(1, 1, 1, 1.0)
		_knob_position = Vector2.ZERO
		_knob.position = Vector2.ZERO

func set_visible(visible: bool) -> void:
	_visible = visible
	if not visible:
		_hide_joystick()