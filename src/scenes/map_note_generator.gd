extends MapNodeGenerator
class_name MapNoteGenerator

var _tile_size := Vector2i(0, 0)
var _centre_vector := Vector2(0, 0)

@export var note: Interactable = null

func _ready():
	assert(map_generator != null)
	self._tile_size = map_generator.wall_tile_map.tile_set.tile_size
	self._centre_vector = Vector2(self._tile_size)/2
	super._ready()

func generate_object(pos: Vector2i) -> bool:
	var gem: Node = note.duplicate()
	gem.visible = true
	var gem_pos := Vector2(pos.x * self._tile_size.x, pos.y * self._tile_size.y)
	gem_pos += self._centre_vector
	self.add_child(gem)
	gem.set_position(gem_pos)
	return true
