@tool

extends TileMapLayer
class_name MazeMap
@export_range(1, 100, 1) var size_columns: int = 200:
	set(value):
		size_columns = value
		self._ready()

@export_range(1, 100, 1)  var size_rows: int = 200

@export_range(10, INF, 1) var min_stack_size: int = 10
@export_range(0, 1) var path_give_up_chance: float = 0.20
@export_range(0, 1) var branch_give_up_chance: float = 0.75

@export var starting_point = Vector2i(1, 1)

var map: Array[Array] = []

const POSSIBLE_X_DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
]
const POSSIBLE_Y_DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(0, -1),
]

enum MazePart {
	EMPTY = 0,
	WALL = 1,
}

func is_empty(pos: Vector2i) -> bool:
	return self.map[pos.y][pos.x] == MazePart.EMPTY

func is_wall(pos: Vector2i) -> bool:
	return self.map[pos.y][pos.x] == MazePart.WALL


func initialise_map() -> void:
	self.map.clear()
	self.map.resize(self.size_rows + 1)
	for row: Array[MazePart] in self.map:
		row.resize(self.size_columns + 1)
		row.fill(MazePart.WALL)

func is_neighbour(pos1: Vector2i, pos2: Vector2i, diagonal: bool = false) -> bool:
	var vec: Vector2i = abs(pos1 - pos2)
	if is_equal_approx(vec.length(), 1):
		return true
	if diagonal and vec.x == 1 and vec.y == 1:
		return true
	return false

func get_neighbours(pos: Vector2i, diagonal: bool = false) -> Array[Vector2i]:
	var res: Array[Vector2i] = []
	for x_dir: Vector2i in POSSIBLE_X_DIRECTIONS:
		res.push_back(pos + x_dir)
		if not diagonal:
			continue
		for y_dir: Vector2i in POSSIBLE_Y_DIRECTIONS:
			res.push_back(pos + x_dir + y_dir)
	for y_dir: Vector2i in POSSIBLE_Y_DIRECTIONS:
		res.push_back(pos + y_dir)
	return res

func is_valid_pos(pos: Vector2i) -> bool:
	return (pos.x > 0\
			and pos.y > 0\
			and pos.x < self.size_columns\
			and pos.y < self.size_rows)

func get_empty_neighbours_count(pos: Vector2i, diagonal: bool = false) -> int:
	assert(is_valid_pos(pos))
	var empty_neigbours: int = 0
	var neighbours = get_neighbours(pos, diagonal)
	for neighbour: Vector2i in neighbours:
		if self.is_empty(neighbour):
			empty_neigbours += 1
	return empty_neigbours

func is_path(pos: Vector2i) -> bool:
	assert(is_valid_pos(pos))
	if self.get_empty_neighbours_count(pos) >= 2:
		return true
	return false

## Get neighbours in cone to the current tile
func get_cone_neighbours(prev: Vector2i, next: Vector2i) -> Array[Vector2i]:
	assert(is_valid_pos(prev))
	assert(is_valid_pos(next))
	
	var all_neighbours := get_neighbours(next, true)
	var cone_neighbours: Array[Vector2i] = []
	for neigh: Vector2i in all_neighbours:
		if not is_neighbour(neigh, prev) and not neigh == prev:
			cone_neighbours.push_back(neigh)
	return cone_neighbours

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
		for direction in (POSSIBLE_X_DIRECTIONS + POSSIBLE_Y_DIRECTIONS):
			var cell_to_check = current + direction
			if is_valid_pos(cell_to_check)\
				and not visited.has(cell_to_check)\
				and not self.get_cone_neighbours(current, cell_to_check).any(is_empty):
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
	self.clear()
	for y in range(map.size()):
		for x in range(map[y].size()):
			var tile := Vector2i(1, 1) if self.map[y][x] == MazePart.WALL else Vector2i(4, 1) # those are the atlas coordinates
			self.set_cell(
					Vector2i(x, y),
					0,
					tile
				)
