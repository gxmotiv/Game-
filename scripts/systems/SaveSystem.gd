extends Node

signal save_completed(success: bool)
signal load_completed(success: bool, data: Dictionary)

const SAVE_SLOT_COUNT = 3
const SAVE_FILE_PREFIX = "user://save_slot_"
const SAVE_FILE_EXT = ".sav"

var _current_slot: int = 0

func _ready() -> void:
	pass

func save_game(slot: int = -1, game_data: Dictionary = {}) -> void:
	if slot == -1:
		slot = _current_slot
	
	if slot < 0 or slot >= SAVE_SLOT_COUNT:
		push_error("Invalid save slot: ", slot)
		save_completed.emit(false)
		return
	
	var save_data = {
		"version": 1,
		"timestamp": Time.get_datetime_dict_from_system(),
		"slot": slot,
		"game_data": game_data
	}
	
	var file = FileAccess.open(SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXT, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		_current_slot = slot
		save_completed.emit(true)
	else:
		push_error("Failed to open save file for writing")
		save_completed.emit(false)

func load_game(slot: int = -1) -> Dictionary:
	if slot == -1:
		slot = _current_slot
	
	if slot < 0 or slot >= SAVE_SLOT_COUNT:
		push_error("Invalid save slot: ", slot)
		load_completed.emit(false, {})
		return {}
	
	var file_path = SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXT
	if not FileAccess.file_exists(file_path):
		load_completed.emit(false, {})
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		if save_data and save_data.has("game_data"):
			load_completed.emit(true, save_data.game_data)
			return save_data.game_data
	
	load_completed.emit(false, {})
	return {}

func has_save(slot: int) -> bool:
	if slot < 0 or slot >= SAVE_SLOT_COUNT:
		return false
	return FileAccess.file_exists(SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXT)

func get_save_info(slot: int) -> Dictionary:
	if slot < 0 or slot >= SAVE_SLOT_COUNT:
		return {}
	
	var file_path = SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXT
	if not FileAccess.file_exists(file_path):
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		if save_data:
			return {
				"timestamp": save_data.get("timestamp", {}),
				"version": save_data.get("version", 1),
				"slot": slot
			}
	
	return {}

func delete_save(slot: int) -> void:
	if slot < 0 or slot >= SAVE_SLOT_COUNT:
		return
	
	var file_path = SAVE_FILE_PREFIX + str(slot) + SAVE_FILE_EXT
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)

func get_all_save_infos() -> Array[Dictionary]:
	var infos = []
	for i in range(SAVE_SLOT_COUNT):
		infos.append(get_save_info(i))
	return infos

func set_current_slot(slot: int) -> void:
	if slot >= 0 and slot < SAVE_SLOT_COUNT:
		_current_slot = slot