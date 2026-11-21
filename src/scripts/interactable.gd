
class_name Interactable
extends Area2D

signal interacted(interactor: Node)

var can_interact_check: Callable  # (interactor: Node) -> bool

@export var prompt_text := "Interact"
@export var is_multiple_use := false 
@export var interact_priority := 1 

var _is_exhausted = false;

func show_interact_prompt() -> void:
	pass

func interact(interactor: Node) -> void:
	if !is_multiple_use:
		_is_exhausted = true
	interacted.emit(interactor)

func can_interact(_interactor: Node) -> bool:
	if can_interact_check.is_valid():
		return is_multiple_use or !_is_exhausted
	else:
		return (is_multiple_use or !_is_exhausted) && can_interact_check.call(_interactor)
