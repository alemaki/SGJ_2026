extends Interactable
class_name Note

func _ready()-> void:
	can_interact_check = self.can_interact_note

func can_interact_note() -> bool:
	return true

func show_interact_prompt() -> void:
	pass
