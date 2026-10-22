extends Node

signal music_volume_changed(volume: float)
signal sfx_volume_changed(volume: float)

var _music_volume: float = 0.7
var _sfx_volume: float = 0.8
var _current_music: AudioStreamPlayer = null
var _music_players: Array[AudioStreamPlayer] = []
var _sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 16

func _ready() -> void:
	_init_sfx_pool()

func _init_sfx_pool() -> void:
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)

func play_music(stream: AudioStream, fade_time: float = 1.0) -> void:
	if _current_music and _current_music.playing:
		_fade_out_music(fade_time)
	
	_current_music = AudioStreamPlayer.new()
	_current_music.stream = stream
	_current_music.bus = "Music"
	_current_music.volume_db = linear_to_db(_music_volume)
	_current_music.autoplay = true
	add_child(_current_music)
	_current_music.play()

func _fade_out_music(fade_time: float) -> void:
	if not _current_music:
		return
	
	var tween = create_tween()
	tween.tween_property(_current_music, "volume_db", linear_to_db(0.0), fade_time)
	tween.finished.connect(_on_music_fade_out_finished.bind(_current_music))

func _on_music_fade_out_finished(player: AudioStreamPlayer) -> void:
	if player and is_instance_valid(player):
		player.stop()
		player.queue_free()

func stop_music(fade_time: float = 1.0) -> void:
	if _current_music:
		_fade_out_music(fade_time)
		_current_music = null

func play_sfx(stream: AudioStream, position: Vector2 = Vector2.ZERO, volume_scale: float = 1.0) -> void:
	var player = _get_available_sfx_player()
	if not player:
		return
	
	player.stream = stream
	player.volume_db = linear_to_db(_sfx_volume * volume_scale)
	player.play()

func play_sfx_at_node(stream: AudioStream, node: Node, volume_scale: float = 1.0) -> void:
	var player = _get_available_sfx_player()
	if not player:
		return
	
	player.stream = stream
	player.volume_db = linear_to_db(_sfx_volume * volume_scale)
	if node is Node2D:
		player.global_position = node.global_position
	player.play()

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	
	var oldest_player = _sfx_players[0]
	var oldest_time = oldest_player.get_playback_position()
	for player in _sfx_players:
		if player.get_playback_position() > oldest_time:
			oldest_player = player
			oldest_time = player.get_playback_position()
	return oldest_player

func set_music_volume(volume: float) -> void:
	_music_volume = clamp(volume, 0.0, 1.0)
	if _current_music:
		_current_music.volume_db = linear_to_db(_music_volume)
	music_volume_changed.emit(_music_volume)

func set_sfx_volume(volume: float) -> void:
	_sfx_volume = clamp(volume, 0.0, 1.0)
	sfx_volume_changed.emit(_sfx_volume)

func get_music_volume() -> float:
	return _music_volume

func get_sfx_volume() -> float:
	return _sfx_volume

func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log10(linear)