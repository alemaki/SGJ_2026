class_name WallStacker
extends Node2D

@export var source: TileMapLayer
@export var hide_source := true
@export var slices := 16
@export var bottom_depth := 1.0
@export var top_depth := 1.18
@export var bottom_color := Color(0.2, 0.18, 0.25)
@export var top_color := Color.WHITE


func _ready() -> void:
	for i in slices:
		var t := i / float(slices - 1)
		var layer := DepthLayer.new()
		layer.depth = lerpf(bottom_depth, top_depth, t)

		var copy := TileMapLayer.new()
		copy.tile_set = source.tile_set
		copy.tile_map_data = source.tile_map_data
		copy.collision_enabled = false
		if i != slices - 1:
			copy.occlusion_enabled = false
		copy.modulate = bottom_color.lerp(top_color, t * t)

		layer.add_child(copy)
		add_child(layer)

	if hide_source:
		source.visible = false
