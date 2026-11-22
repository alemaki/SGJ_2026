@tool
extends Node2D
class_name MapNodeGenerator
# Interface

@export var map_generator: MazeGenerator = null

## Percent of map generated
@export_range(0, 1, 0.01) var intensity: float = 0.05

# Currently useless.
@export_range(0, 1000, 1) var min_nodes: int = 0
# Currently useless.
@export_range(0, 1000, 1) var max_nodes: int = 1000

@export_range(0, 20, 1) var min_distance: int = 1

func _ready() -> void:
	assert(map_generator != null)
	generate_objects()

func generate_objects():
	#var total_objects_generated = 0
	var generated_on: Dictionary[Vector2i, bool] = {}
	for row: int in self.map_generator.map.size():
		for column: int in self.map_generator.map[row].size():
			var tile: MazeGenerator.MazePart = self.map_generator.map[row][column]
			var pos := Vector2i(column, row) # column is x
			# do we care if generate more than one object type on one tile. probably not.
			if tile != MazeGenerator.MazePart.EMPTY:
				continue
			var generate := true
			for neighbour: Vector2i in self.map_generator.get_neighbours(pos, self.min_distance, true):
				if generated_on.has(neighbour):
					generate = false
			if randf() > intensity:
				generate = false
			if generate and self.generate_object(pos):
				generated_on[pos] = true
				#total_objects_generated += 1

func generate_object(_pos: Vector2i) -> bool:
	return true
