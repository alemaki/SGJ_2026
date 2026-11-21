
class_name InteractableSensor
extends Area2D

var _interactable_candidates: Array[Interactable] = []

func _ready() -> void:
	area_entered.connect(_on_interactable_entered)
	area_exited.connect(_on_interactable_exited)

func _on_interactable_entered(area: Area2D) -> void:
	if area is Interactable:
		_interactable_candidates.append(area)

func _on_interactable_exited(area: Area2D) -> void:
	if area is Interactable:
		_interactable_candidates.erase(area)
		
func request_interaction() -> bool:
	if _interactable_candidates.is_empty():
		return false;
		
	var current_best_priority := -INF
	var current_best_interactable: Interactable
	for interactable_candidate in _interactable_candidates:
		if current_best_priority < interactable_candidate.priority:
			current_best_priority = interactable_candidate.priority
			current_best_interactable = interactable_candidate
			
	if current_best_interactable.can_interact(get_parent()):
		current_best_interactable.interact(get_parent())
		return true
	else:
		return false;
