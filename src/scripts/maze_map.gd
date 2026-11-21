@tool
extends Node
class_name MazeGenerator

@export var wall_tile_map: TileMapLayer = null
@export var ground_tile_map: TileMapLayer = null

@export_range(1, 100, 1) var size_columns: int = 80
@export_range(1, 100, 1)  var size_rows: int = 80

@export_range(10, INF, 1) var min_stack_size: int = 10
@export_range(0, 1) var path_give_up_chance: float = 0.008
@export_range(0, 1) var branch_give_up_chance: float = 0.97

@export var starting_point = Vector2i(2, 2)

@export_range(1, INF, 1) var neighbour_distance: int = 3

var map: Array[Array] = []

enum MazePart {
	EMPTY = 0,
	WALL = 1,
}

func is_empty(pos: Vector2i) -> bool:
	return self.map[pos.y][pos.x] == MazePart.EMPTY

func is_wall(pos: Vector2i) -> bool:
	return self.map[pos.y][pos.x] == MazePart.WALL


func initialise_map() -> void:
	map.clear()
	for y in range(size_rows + neighbour_distance):
		var row: Array[int] = []
		row.resize(size_columns + neighbour_distance)
		row.fill(MazePart.WALL)
		map.append(row)

func is_close_neighbour(
		pos1: Vector2i,
		pos2: Vector2i,
		distance: int = 1,
		) -> bool:
	var vec: Vector2i = abs(pos1 - pos2)
	return vec.x <= distance\
			and vec.y <= distance\
			and not (vec.x == 0 and vec.y == 0)

func get_neighbours(pos: Vector2i, distance: int = 1, diagonaly: bool = false) -> Array[Vector2i]:
	var res: Array[Vector2i] = []
	for x in range(-distance, distance + 1):
		for y in range(-distance, distance + 1):
			if x == 0 and y == 0:
				continue
			if (not diagonaly) and x != 0 and y != 0:
				continue
			res.append(pos + Vector2i(x, y))
	return res

func is_valid_pos(pos: Vector2i) -> bool:
	return (pos.x > 0\
			and pos.y > 0\
			and pos.x < self.size_columns\
			and pos.y < self.size_rows)

func get_empty_neighbours_count(pos: Vector2i, distance: int = 1, diagonaly = false) -> int:
	assert(is_valid_pos(pos))
	var empty_neigbours: int = 0
	var neighbours = get_neighbours(pos, distance, diagonaly)
	for neighbour: Vector2i in neighbours:
		if self.is_empty(neighbour):
			empty_neigbours += 1
	return empty_neigbours

func is_path(pos: Vector2i) -> bool:
	assert(is_valid_pos(pos))
	if self.get_empty_neighbours_count(pos, 1) >= 2:
		return true
	return false

## Get neighbours in cone to the current tile
func get_cone_neighbours(
		prev: Vector2i,
		next: Vector2i,
		distance: int = 1
		) -> Array[Vector2i]:
	var cone: Array[Vector2i] = []
	var direction := next - prev
	for neighbour in self.get_neighbours(next, distance, true):
		var offset := neighbour - next
		if offset == Vector2i.ZERO:
			continue
		if Vector2(offset).dot(Vector2(direction)) < 0:
			continue
		cone.append(neighbour)
	return cone

## Map will be generated here directly.
func _ready() -> void:
	self.initialise_map()
	var visited: Dictionary[Vector2i, bool] = {}
	var stack: Array[Vector2i] = []
	
	stack.push_back(self.starting_point)
	visited[self.starting_point] = true
	map[self.starting_point.y][self.starting_point.x] = MazePart.EMPTY
	
	while not stack.is_empty():
		var current: Vector2i = stack.back()
		var is_current_path = self.is_path(current)
		# Might skip branching of path when returning for more spaced out branches
		if stack.size() > self.min_stack_size:
			# Might skip branching of path when returning for more spaced out branches
			if is_current_path:
				if randf() <= self.branch_give_up_chance:
					stack.pop_back()
					continue
			# Might skip continuing path so it can branch away
			else:
				if randf() <= self.branch_give_up_chance:
					var vec: Vector2i= stack.pop_back()
					stack.push_front(vec)# finish later.
					continue
		
		var possible_neighbours: Array[Vector2i] = []
		for cell_to_check in self.get_neighbours(current, 1, false):
			if is_valid_pos(cell_to_check)\
				and not visited.has(cell_to_check)\
				and not self.get_cone_neighbours(current, cell_to_check, self.neighbour_distance).any(is_empty):
				possible_neighbours.push_back(cell_to_check)
		
		if possible_neighbours.is_empty():
			stack.pop_back()
			continue
		var next: Vector2i = possible_neighbours.pick_random()
		self.map[next.y][next.x] = MazePart.EMPTY
		visited[next] = true
		stack.push_back(next)
	
	self.draw_maze()

func draw_maze() -> void:
	assert(wall_tile_map != null)
	assert(ground_tile_map != null)
	wall_tile_map.clear()
	ground_tile_map.clear()
	var wall_cells: Array[Vector2i] = []
	var ground_cells: Array[Vector2i] = []
	var path_cells: Array[Vector2i] = []
	for y in range(-self.neighbour_distance, size_rows + self.neighbour_distance):
		for x in range(-self.neighbour_distance, size_columns + self.neighbour_distance):
			var pos := Vector2i(x, y)
			if map[y][x] == MazePart.WALL:
				wall_cells.append(pos)
			else:
				path_cells.append(pos)
				for neigh: Vector2i in self.get_neighbours(pos, 1, true):
					for neigh2: Vector2i in self.get_neighbours(neigh, 1, true):
						ground_cells.append(neigh2)
	wall_tile_map.set_cells_terrain_connect(wall_cells, 0, 0)
	ground_tile_map.set_cells_terrain_connect(ground_cells, 0, 1)
	ground_tile_map.set_cells_terrain_connect(path_cells, 0, 2)
