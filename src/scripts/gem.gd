
class_name Gem

extends Node2D

@export var hits_needed_to_collect := 2
@export var score_reward := 10

@onready var interactable: Interactable = $Interactable

var _hits_taken := 0;

func _ready() -> void:
	interactable.can_interact_check = _can_interact
	interactable.on_interaction.connect(_take_hit)

func _can_interact(interactor: Node) -> bool:
	return hits_needed_to_collect < _hits_taken
	
func _take_hit(interactor: Node) -> void:
	_hits_taken += 1
	if (_hits_taken == hits_needed_to_collect):
		# 1. Play on pick up VFX
		# 2. Add score
		get_parent().queue_free()
