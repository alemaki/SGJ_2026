extends Node
class_name Main

@export var player: CharacterBody2D = null
@export var mapNode: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(mapNode != null)
	assert(player != null)
	var map = mapNode.get_node("TileMapLayer")
	player.position.x = map.starting_point.x * map.tile_set.tile_size.x
	player.position.y = map.starting_point.y * map.tile_set.tile_size.y


func _on_player_character_player_death(final_score: int) -> void:
	# TODO: Find out whether the game won.
	DHOSceneManager.switch_to_save_score_scene(self.get_tree(), final_score, false)
