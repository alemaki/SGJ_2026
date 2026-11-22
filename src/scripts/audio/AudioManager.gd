class_name AudioManager
extends Node

static var _instance: AudioManager = null
@export var soundEffects: Dictionary[String,AudioStreamPlayer] = {}

static func getInstance() -> AudioManager:
	if _instance==null:
		_instance = AudioManager.new()
		var tree = Engine.get_main_loop() as SceneTree
		tree.current_scene.add_child(_instance)
	return _instance

func playAudio(effect: String) -> void:
	if !soundEffects.has(effect):
		print("No audio file {effect} isn't loaded")
		return
	if soundEffects[effect].playing:
		return
	soundEffects[effect].play();

func pauseAudio(effect: String) -> void:
	if !soundEffects.has(effect):
		return
	soundEffects[effect].pause()

func playAndLoadAudio(
	effect: String,
	file: String,
	bus: String,
	volume_db: float,
	loop:bool = false) -> void:
		if !soundEffects.has(effect):
			loadAudio(effect,file,bus,volume_db)
		playAudio(effect)

func loadAudio(
	effect: String,
	file: String,
	bus: String,
	volume_db: float,
	loop:bool = false) -> void:
	if soundEffects.has(effect):
		soundEffects[effect].bus = bus
		soundEffects[effect].volume_db = volume_db
		soundEffects[effect].stream.loop = loop
		return
	soundEffects[effect] = AudioStreamPlayer.new()
	soundEffects[effect].stream = load(file)
	soundEffects[effect].bus = bus
	soundEffects[effect].volume_db = volume_db
	soundEffects[effect].stream.loop = loop
	add_child(soundEffects[effect])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_instance = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
