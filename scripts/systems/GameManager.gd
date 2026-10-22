extends Node

signal game_paused(paused: bool)
signal game_over(caught: bool)
signal level_changed(level_name: String)
signal settings_changed(settings: Dictionary)

enum GameState { PLAYING, PAUSED, GAME_OVER, MAIN_MENU }

var _game_state: GameState = GameState.PLAYING
var _current_level: String = "res://scenes/level/Level.tscn"
var _settings: Dictionary = {
	"use_tap_move": false,
	"music_volume": 0.7,
	"sfx_volume": 0.8,
	"show_detection_meter": true,
	"controls_scheme": "virtual_joystick"
}
var _player_start_position: Vector2 = Vector2(100, 100)

func _ready() -> void:
	_load_settings()

func _load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		_settings.use_tap_move = config.get_value("settings", "use_tap_move", false)
		_settings.music_volume = config.get_value("settings", "music_volume", 0.7)
		_settings.sfx_volume = config.get_value("settings", "sfx_volume", 0.8)
		_settings.show_detection_meter = config.get_value("settings", "show_detection_meter", true)
		_settings.controls_scheme = config.get_value("settings", "controls_scheme", "virtual_joystick")
	settings_changed.emit(_settings)

func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("settings", "use_tap_move", _settings.use_tap_move)
	config.set_value("settings", "music_volume", _settings.music_volume)
	config.set_value("settings", "sfx_volume", _settings.sfx_volume)
	config.set_value("settings", "show_detection_meter", _settings.show_detection_meter)
	config.set_value("settings", "controls_scheme", _settings.controls_scheme)
	config.save("user://settings.cfg")

func get_game_state() -> GameState:
	return _game_state

func set_game_state(state: GameState) -> void:
	_game_state = state
	if state == GameState.PAUSED:
		game_paused.emit(true)
		get_tree().paused = true
	elif state == GameState.PLAYING:
		game_paused.emit(false)
		get_tree().paused = false

func toggle_pause() -> void:
	if _game_state == GameState.PLAYING:
		set_game_state(GameState.PAUSED)
	elif _game_state == GameState.PAUSED:
		set_game_state(GameState.PLAYING)

func trigger_game_over(caught: bool) -> void:
	set_game_state(GameState.GAME_OVER)
	game_over.emit(caught)

func restart_level() -> void:
	get_tree().reload_current_scene()

func get_current_level() -> String:
	return _current_level

func set_current_level(level_path: String) -> void:
	_current_level = level_path
	level_changed.emit(level_path)

func get_player_start_position() -> Vector2:
	return _player_start_position

func set_player_start_position(pos: Vector2) -> void:
	_player_start_position = pos

func get_settings() -> Dictionary:
	return _settings.duplicate()

func set_setting(key: String, value: Variant) -> void:
	if _settings.has(key):
		_settings[key] = value
		_save_settings()
		settings_changed.emit(_settings)

func get_setting(key: String) -> Variant:
	return _settings.get(key, null)