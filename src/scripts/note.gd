extends Interactable
class_name Note

@export var note_ui: NoteUI = null

func _ready()-> void:
	if note_ui != null:
		self.on_note.connect(note_ui.noted)
	can_interact_check = self.can_interact_note

func can_interact_note() -> bool:
	return true

func show_interact_prompt() -> void:
	pass
