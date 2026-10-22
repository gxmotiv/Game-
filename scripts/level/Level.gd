extends Node2D

class_name Level

@export var tile_size: Vector2i = Vector2i(32, 32)
@export var map_size: Vector2i = Vector2i(40, 30)

var _tile_map: TileMapLayer
var _navigation_region: NavigationRegion2D
var _player_start: Marker2D
var _guard_waypoints: Array[Marker2D] = []

func _ready() -> void:
	_build_level()
	_setup_navigation()

func _build_level() -> void:
	_tile_map = TileMapLayer.new()
	_tile_map.name = "TileMap"
	_tile_map.tile_set = _create_tile_set()
	add_child(_tile_map)
	
	_navigation_region = NavigationRegion2D.new()
	_navigation_region.name = "NavigationRegion"
	_navigation_region.use_edge_connections = true
	add_child(_navigation_region)
	
	_player_start = Marker2D.new()
	_player_start.name = "PlayerStart"
	_player_start.position = Vector2(tile_size.x * 2, tile_size.y * 2)
	add_child(_player_start)
	
	_create_walls()
	_create_rooms()
	_create_doors()
	_create_guard_waypoints()

func _create_tile_set() -> TileSet:
	var tile_set = TileSet.new()
	
	var source = TileSetAtlasSource.new()
	source.texture = _create_tile_textures()
	source.margins = Vector2i(0, 0)
	source.separation = Vector2i(0, 0)
	source.texture_region_size = tile_size
	tile_set.add_source(source, 0)
	
	var floor_atlas_coords = Vector2i(0, 0)
	var wall_atlas_coords = Vector2i(1, 0)
	var door_atlas_coords = Vector2i(2, 0)
	var void_atlas_coords = Vector2i(3, 0)
	
	var floor_tile = TileSetTile.new()
	floor_tile.atlas_coords = floor_atlas_coords
	tile_set.add_tile(0, Vector2i(0, 0), floor_tile)
	
	var wall_tile = TileSetTile.new()
	wall_tile.atlas_coords = wall_atlas_coords
	var wall_shape = RectangleShape2D.new()
	wall_shape.size = Vector2(tile_size.x, tile_size.y)
	wall_tile.add_shape(0, wall_shape)
	wall_tile.collision_layer = 4
	wall_tile.collision_mask = 1
	wall_tile.z_index = 1
	tile_set.add_tile(0, Vector2i(1, 0), wall_tile)
	
	var door_tile = TileSetTile.new()
	door_tile.atlas_coords = door_atlas_coords
	var door_shape = RectangleShape2D.new()
	door_shape.size = Vector2(tile_size.x, tile_size.y)
	door_tile.add_shape(0, door_shape)
	door_tile.collision_layer = 4
	door_tile.collision_mask = 1
	door_tile.z_index = 1
	tile_set.add_tile(0, Vector2i(2, 0), door_tile)
	
	var void_tile = TileSetTile.new()
	void_tile.atlas_coords = void_atlas_coords
	tile_set.add_tile(0, Vector2i(3, 0), void_tile)
	
	return tile_set

func _create_tile_textures() -> ImageTexture:
	var img = Image.create(tile_size.x * 4, tile_size.y, false, Image.FORMAT_RGBA8)
	
	var floor_color = Color(0.2, 0.2, 0.25)
	var wall_color = Color(0.4, 0.35, 0.3)
	var door_color = Color(0.5, 0.3, 0.2)
	var void_color = Color(0.05, 0.05, 0.1)
	
	for x in range(tile_size.x):
		for y in range(tile_size.y):
			var fx = x + randf() * 2 - 1
			var fy = y + randf() * 2 - 1
			var noise = sin(fx * 0.5) * cos(fy * 0.5) * 0.05
			img.set_pixel(x, y, floor_color + Color(noise, noise, noise, 0))
	
	for x in range(tile_size.x):
		for y in range(tile_size.y):
			var wx = x + tile_size.x
			var wy = y
			var noise = sin(wx * 0.3) * cos(wy * 0.3) * 0.08
			img.set_pixel(wx, wy, wall_color + Color(noise, noise, noise, 0))
		
		for dy in range(3):
			img.set_pixel(wx, dy, Color(0.2, 0.15, 0.1, 1))
			img.set_pixel(wx, tile_size.y - 1 - dy, Color(0.2, 0.15, 0.1, 1))
	
	for x in range(tile_size.x):
		for y in range(tile_size.y):
			var dx = x + tile_size.x * 2
			var dy = y
			var noise = sin(dx * 0.4) * 0.1
			img.set_pixel(dx, dy, door_color + Color(noise, noise, noise, 0))
		
		for dy in range(4):
			img.set_pixel(dx, dy, Color(0.3, 0.15, 0.1, 1))
			img.set_pixel(dx, tile_size.y - 1 - dy, Color(0.3, 0.15, 0.1, 1))
	
	for x in range(tile_size.x):
		for y in range(tile_size.y):
			img.set_pixel(x + tile_size.x * 3, y, void_color)
	
	var texture = ImageTexture.create_from_image(img)
	return texture

func _create_walls() -> void:
	for x in range(map_size.x):
		_tile_map.set_cell(Vector2i(x, 0), 0, Vector2i(1, 0))
		_tile_map.set_cell(Vector2i(x, map_size.y - 1), 0, Vector2i(1, 0))
	
	for y in range(map_size.y):
		_tile_map.set_cell(Vector2i(0, y), 0, Vector2i(1, 0))
		_tile_map.set_cell(Vector2i(map_size.x - 1, y), 0, Vector2i(1, 0))

func _create_rooms() -> void:
	var rooms = [
		{"pos": Vector2i(5, 5), "size": Vector2i(10, 8)},
		{"pos": Vector2i(20, 5), "size": Vector2i(12, 8)},
		{"pos": Vector2i(5, 18), "size": Vector2i(15, 10)},
		{"pos": Vector2i(25, 18), "size": Vector2i(10, 10)},
	]
	
	for room in rooms:
		var pos = room.pos
		var size = room.size
		
		for x in range(size.x):
			for y in range(size.y):
				var cell_pos = Vector2i(pos.x + x, pos.y + y)
				_tile_map.set_cell(cell_pos, 0, Vector2i(0, 0))
		
		_tile_map.set_cell(Vector2i(pos.x, pos.y + size.y / 2), 0, Vector2i(2, 0))
		if pos.x + size.x < map_size.x - 1:
			_tile_map.set_cell(Vector2i(pos.x + size.x, pos.y + size.y / 2), 0, Vector2i(2, 0))
		if pos.y + size.y < map_size.y - 1:
			_tile_map.set_cell(Vector2i(pos.x + size.x / 2, pos.y + size.y), 0, Vector2i(2, 0))

func _create_doors() -> void:
	var doors = [
		Vector2i(10, 10),
		Vector2i(25, 10),
		Vector2i(12, 25),
		Vector2i(30, 25),
	]
	
	for door_pos in doors:
		_tile_map.set_cell(door_pos, 0, Vector2i(2, 0))

func _create_guard_waypoints() -> void:
	var guard1_waypoints = [
		Vector2(tile_size.x * 6, tile_size.y * 6),
		Vector2(tile_size.x * 12, tile_size.y * 6),
		Vector2(tile_size.x * 12, tile_size.y * 10),
		Vector2(tile_size.x * 6, tile_size.y * 10),
	]
	
	var guard2_waypoints = [
		Vector2(tile_size.x * 22, tile_size.y * 6),
		Vector2(tile_size.x * 28, tile_size.y * 6),
		Vector2(tile_size.x * 28, tile_size.y * 10),
		Vector2(tile_size.x * 22, tile_size.y * 10),
	]
	
	var guard3_waypoints = [
		Vector2(tile_size.x * 8, tile_size.y * 20),
		Vector2(tile_size.x * 18, tile_size.y * 20),
		Vector2(tile_size.x * 18, tile_size.y * 25),
		Vector2(tile_size.x * 8, tile_size.y * 25),
	]
	
	_guard_waypoints = [guard1_waypoints, guard2_waypoints, guard3_waypoints]

func _setup_navigation() -> void:
	var nav_mesh = NavigationMesh.new()
	nav_mesh.cell_size = tile_size.x
	nav_mesh.agent_radius = 16
	nav_mesh.agent_height = 32
	nav_mesh.agent_max_climb = 16
	nav_mesh.agent_max_slope = 45.0
	nav_mesh.parse_source_geometry_mode = NavigationMesh.PARSE_SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
	
	var nav_mesh_source = NavigationMeshSourceGeometryData2D.new()
	nav_mesh_source.root_node = _tile_map
	nav_mesh_source.groups_with_children = ["wall"]
	
	nav_mesh.bake_from_source_geometry_data(nav_mesh_source)
	_navigation_region.navigation_mesh = nav_mesh

func get_player_start_position() -> Vector2:
	return _player_start.global_position

func get_guard_waypoints(guard_index: int) -> Array[Vector2]:
	if guard_index >= 0 and guard_index < _guard_waypoints.size():
		return _guard_waypoints[guard_index].duplicate()
	return []

func get_tile_map() -> TileMapLayer:
	return _tile_map

func get_navigation_region() -> NavigationRegion2D:
	return _navigation_region