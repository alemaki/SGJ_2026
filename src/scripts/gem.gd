
class_name Gem

extends Node2D

@export var hits_needed_to_collect := 2
@export var score_reward := 10

@export var light_grow_and_shrink_duration: float = 0.3

@onready var interactable: Interactable = $Interactable
@onready var highlightable: Highlightable = $Highlightable
@onready var glow: PointLight2D = $Glow

@export var animation_player: AnimatedSprite2D = null

var _glow_tween: Tween
var _hits_taken := 0;

func _ready() -> void:
	interactable.can_interact_check = _can_interact
	interactable.on_interaction.connect(_take_hit)
	highlightable.on_interaction.connect(_toggle_glow)

func _can_interact(_interactor: Node) -> bool:
	return hits_needed_to_collect > _hits_taken

func _take_hit(_interactor: Node) -> void:
	_hits_taken += 1
	if (_hits_taken == hits_needed_to_collect):
		# 1. Play on pick up VFX
		# 2. Add score
		self.queue_free()
		GlobalEvents.emit_signal("gem_collected", score_reward)

func _toggle_glow(is_glow_on: bool) ->void:
	if _glow_tween:
		_glow_tween.kill()

	if is_glow_on:
		_grow_light()
	else:
		_shrink_light()

func _grow_light() -> void:
	_glow_tween = glow.create_tween().set_parallel(true)
	_glow_tween.tween_property(glow, "energy", 1, light_grow_and_shrink_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _shrink_light() -> void:
	_glow_tween = glow.create_tween().set_parallel(true)
	_glow_tween.tween_property(glow, "energy", 0.0, light_grow_and_shrink_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func set_random_sprite() -> void:
	var frames_count: int = animation_player.sprite_frames.get_frame_count("default")
	animation_player.frame = randi_range(0, frames_count)
