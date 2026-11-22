extends Control
class_name NoteUI

@export var noteSprite: Sprite2D = null;
@export var textDisplay: RichTextLabel = null;
@export var textNotes: Dictionary[int,String] = {}
@export var currIndex: int = 0

var interactable: Node = null
var openNote: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_tree().current_scene.get_children():
		if child is Interactable:
			child.on_note.connect(noted)

func noted() -> void:
	if currIndex == textNotes.size():
		textDisplay.text = "TWljaGFlbCBBZGxlciB3YXMgaGVyZQpWR2hsSUVkc2FYUmphQT09IGlzIGFmdGVyIG1lCkhFTFAgTUU="
	else:
		textDisplay.text = textNotes[currIndex]
	self.visible = true
	openNote = true
	Engine.time_scale = 0

func denoted() -> void:
	openNote = false
	self.visible = false
	Engine.time_scale = 1.0
	if currIndex < textNotes.size():
		currIndex+=1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_0):
		noted()
	if (Input.is_action_just_pressed("ui_accept_device_0") || Input.is_key_pressed(KEY_1)) && openNote:
		denoted()
