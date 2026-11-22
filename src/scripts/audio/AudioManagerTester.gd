class_name AudioManagerTester
extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_A):
		var manager = AudioManager.getInstance()
		manager.loadAudio("scream","res://assets/audio/sfx/walking-gravel-sound.mp3","Echo",-20.0)
		manager.playAudio("scream")
