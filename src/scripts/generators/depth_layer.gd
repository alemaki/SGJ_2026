class_name DepthLayer
extends Node2D
@export var depth := 1.0


func _ready() -> void:
	process_priority = 100  # update after the camera

func _process(_delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	var c := cam.get_screen_center_position()
	scale = Vector2.ONE * depth
	position = c * (1.0 - depth)
