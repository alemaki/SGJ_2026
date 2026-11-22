class_name Highlighter

extends Area2D

@export var highlight_grow_duration: float = 1.1
@export var highlight_shrink_duration: float = 0.4
@export var highlight_radius: float = 200.0


@onready var collision_shape: CollisionShape2D = $HighlightCollision

var _area_scale_tween: Tween
var _is_currently_highlighting = false

func _ready() -> void:
	# Duplicate the collision shape in order to avoid scaling other collision shapes
	collision_shape.shape = collision_shape.shape.duplicate()
	area_entered.connect(_on_highlightable_entered)
	area_exited.connect(_on_highlightable_exited)
	
func toggle_highlighting() -> void:
	_is_currently_highlighting = not _is_currently_highlighting
	if _area_scale_tween:
		_area_scale_tween.kill()

	if _is_currently_highlighting:
		_grow_area()
	else:
		_shrink_area()

func _on_highlightable_entered(area: Area2D) -> void:
	if area is Highlightable:
		area.switch_highlight()

func _on_highlightable_exited(area: Area2D) -> void:
	if area is Highlightable:
		area.switch_highlight()

func _grow_area() -> void:
	_area_scale_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_area_scale_tween.tween_property(collision_shape.shape, "radius", highlight_radius, highlight_grow_duration)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _shrink_area() -> void:
	_area_scale_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_area_scale_tween.tween_property(collision_shape.shape, "radius", 5.0, highlight_shrink_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
