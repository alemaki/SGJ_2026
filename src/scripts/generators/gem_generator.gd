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
	var offset_tiles := Vector2.ZERO
	# Add half offsets for x and y where necesarry + 10% error margin
	if gem_dir.is_equal_approx(Vector2i.RIGHT):
		offset_tiles = Vector2(0.1, 0.5)
	if gem_dir.is_equal_approx(Vector2i.LEFT):
		offset_tiles = Vector2(0.9, 0.5)
	if gem_dir.is_equal_approx(Vector2i.UP):
		offset_tiles = Vector2(0.5, 0.9)
	if gem_dir.is_equal_approx(Vector2i.DOWN):
		offset_tiles = Vector2(0.5, 0.1)
	var offset: Vector2 = offset_tiles * Vector2(self._tile_size)
	print(offset)
	gem_pos += offset
	self.add_child(gem)
	gem.set_position(gem_pos)
	return true
	
