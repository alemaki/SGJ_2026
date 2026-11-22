extends Camera2D
class_name PlayerCamera

@export var map_generator: MazeGenerator = null 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.map_generator == null:
		return
	self.limit_left = 0
	self.limit_top = 0
	var vec: Vector2i = map_generator.get_pixel_size()
	self.limit_right = vec.x
	self.limit_bottom = vec.y
