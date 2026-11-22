@tool
extends MapNodeGenerator
class_name MapGemGenerator
# Interface

var _tile_size := Vector2i(0, 0)
var _centre_vector := Vector2(0, 0)

@export var node_scenes: Array[PackedScene] = [
	preload("res://src/scenes/gems/gem_emerald.tscn"),
	preload("res://src/scenes/gems/gem_ruby.tscn"),
	preload("res://src/scenes/gems/gem_saphire.tscn"),
]

func _ready():
	assert(map_generator != null)
	self._tile_size = map_generator.wall_tile_map.tile_set.tile_size
	self._centre_vector = Vector2(self._tile_size)/2
	super._ready()

func generate_object(pos: Vector2i) -> bool:
	var gem: Gem = node_scenes.pick_random().instantiate()
	var gem_og_direction = Vector2(0, 1)
	var neighbours: Array[Vector2i] = self.map_generator.get_neighbours(pos, 1, false)
	var walls: Array[Vector2i] = neighbours.filter(self.map_generator.is_wall)
	if walls.size() == 0:
		gem.queue_free()
		return false
	var wall_pos: Vector2i = walls.pick_random()
	var gem_dir := Vector2(wall_pos - pos)
	gem.rotate(gem_og_direction.angle_to(gem_dir))
	var gem_pos := Vector2(wall_pos.x * self._tile_size.x, wall_pos.y * self._tile_size.y)
	#var gem_pos = Vector2( # do not forget reversed column and row
		#wall_pos.y * self._tile_size.x,# + (abs(gem_dir.x) + 1) * self._tile_size.x * 1/2,
		#wall_pos.x * self._tile_size.y,# + (abs(gem_dir.y) + 1) * self._centre_vector.y * 1/2,
	#)
	print("path pos: ", pos)
	print("generating gem at: ", wall_pos)
	print("is wall path: ", self.map_generator.is_wall(pos))
	print("is wall wall: ", self.map_generator.is_wall(wall_pos))
	print("gem_pos: ", gem_pos)
	print("gem_dir: ", gem_dir)
	self.add_child(gem)
	gem.set_position(gem_pos)
	return true
	
