extends Node2D

class_name MainGame

@onready var _level: Level = $Level
@onready var _player: Player = $Player
@onready var _guards: Array[Guard] = []
@onready var _hud: CanvasLayer = $HUD
@onready var _virtual_joystick: VirtualJoystick = $HUD/VirtualJoystick
@onready var _pause_menu: Control = $HUD/PauseMenu
@onready var _game_over_menu: Control = $HUD/GameOverMenu
@onready var _settings_menu: Control = $HUD/SettingsMenu

var _guards_data: Array[Dictionary] = []

func _ready() -> void:
	_setup_level()
	_setup_player()
	_setup_guards()
	_setup_hud()
	_setup_signals()
	
	GameManager.set_game_state(GameManager.GameState.PLAYING)

func _setup_level() -> void:
	GameManager.set_current_level("res://scenes/level/Level.tscn")
	GameManager.set_player_start_position(_level.get_player_start_position())

func _setup_player() -> void:
	_player.global_position = _level.get_player_start_position()
	_player.detected_by_guard.connect(_on_player_detected)
	_player.interacted_with.connect(_on_player_interacted)
	_virtual_joystick.direction_changed.connect(_on_joystick_direction_changed)

func _setup_guards() -> void:
	_guards_data = [
		{"scene": preload("res://scenes/guard/Guard.tscn"), "waypoints": _level.get_guard_waypoints(0), "patrol_mode": Guard.PatrolMode.LOOP},
		{"scene": preload("res://scenes/guard/Guard.tscn"), "waypoints": _level.get_guard_waypoints(1), "patrol_mode": Guard.PatrolMode.PING_PONG},
		{"scene": preload("res://scenes/guard/Guard.tscn"), "waypoints": _level.get_guard_waypoints(2), "patrol_mode": Guard.PatrolMode.RANDOM},
	]
	
	for i, data in _guards_data:
		var guard = data.scene.instantiate()
		guard.name = "Guard_" + str(i)
		guard.set_waypoints(data.waypoints)
		guard.patrol_mode = data.patrol_mode
		guard.global_position = data.waypoints[0] if data.waypoints.size() > 0 else _level.get_player_start_position()
		guard.detection_changed.connect(_on_guard_detection_changed.bind(guard))
		guard.player_detected.connect(_on_guard_player_detected.bind(guard))
		_guards.append(guard)
		add_child(guard)

func _setup_hud() -> void:
	_hud.visible = true
	_pause_menu.visible = false
	_game_over_menu.visible = false
	_settings_menu.visible = false
	_virtual_joystick.set_visible(not GameManager.get_setting("use_tap_move", false))
	
	var settings = GameManager.get_settings()
	var tap_toggle = _settings_menu.get_node("SettingsButtons/TapMoveToggle")
	var detection_toggle = _settings_menu.get_node("SettingsButtons/DetectionMeterToggle")
	var music_slider = _settings_menu.get_node("SettingsButtons/MusicVolumeSlider")
	var sfx_slider = _settings_menu.get_node("SettingsButtons/SfxVolumeSlider")
	
	if tap_toggle:
		tap_toggle.button_pressed = settings.get("use_tap_move", false)
	if detection_toggle:
		detection_toggle.button_pressed = settings.get("show_detection_meter", true)
	if music_slider:
		music_slider.value = settings.get("music_volume", 0.7)
	if sfx_slider:
		sfx_slider.value = settings.get("sfx_volume", 0.8)

func _setup_signals() -> void:
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_over.connect(_on_game_over)
	GameManager.settings_changed.connect(_on_settings_changed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		GameManager.toggle_pause()

func _on_game_paused(paused: bool) -> void:
	_pause_menu.visible = paused
	_virtual_joystick.set_visible(not paused and not GameManager.get_setting("use_tap_move", false))
	if paused:
		_pause_menu.grab_focus()

func _on_game_over(caught: bool) -> void:
	_game_over_menu.visible = true
	_virtual_joystick.set_visible(false)
	var label = _game_over_menu.get_node("Message")
	if label:
		label.text = "CAUGHT!" if caught else "ESCAPED!"
	_game_over_menu.grab_focus()

func _on_player_detected(guard: Node) -> void:
	_player.set_detection_level(guard.get_detection_level())

func _on_guard_detection_changed(guard: Guard, level: float) -> void:
	if _player.get_is_crouching():
		level *= 0.5
	_player.set_detection_level(level)

func _on_guard_player_detected(guard: Guard, player: Node) -> void:
	GameManager.trigger_game_over(true)

func _on_player_interacted(object: Node) -> void:
	if object.is_in_group("door"):
		_open_door(object)

func _open_door(door: Node) -> void:
	pass

func _on_joystick_direction_changed(direction: Vector2) -> void:
	InputManager.move_direction_changed.emit(direction)

func _on_pause_resume_pressed() -> void:
	GameManager.toggle_pause()

func _on_pause_restart_pressed() -> void:
	GameManager.restart_level()

func _on_pause_settings_pressed() -> void:
	_pause_menu.visible = false
	_settings_menu.visible = true
	_settings_menu.grab_focus()

func _on_pause_quit_pressed() -> void:
	get_tree().quit()

func _on_game_over_restart_pressed() -> void:
	GameManager.restart_level()

func _on_game_over_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_back_pressed() -> void:
	_settings_menu.visible = false
	if GameManager.get_game_state() == GameManager.GameState.PAUSED:
		_pause_menu.visible = true
		_pause_menu.grab_focus()

func _on_settings_changed(settings: Dictionary) -> void:
	_virtual_joystick.set_visible(GameManager.get_game_state() == GameManager.GameState.PLAYING and not settings.get("use_tap_move", false))

func _on_settings_tap_move_toggled(button: CheckButton) -> void:
	GameManager.set_setting("use_tap_move", button.button_pressed)

func _on_settings_detection_meter_toggled(button: CheckButton) -> void:
	GameManager.set_setting("show_detection_meter", button.button_pressed)

func _on_settings_music_volume_changed(value: float) -> void:
	GameManager.set_setting("music_volume", value)
	AudioManager.set_music_volume(value)

func _on_settings_sfx_volume_changed(value: float) -> void:
	GameManager.set_setting("sfx_volume", value)
	AudioManager.set_sfx_volume(value)