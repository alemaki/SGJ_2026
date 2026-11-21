@tool
extends Control
class_name Vitraj

# ---------- Gems ----------
var _gems: int = 0
@export_range(0, 20, 1, "or_greater") var collected_gems: int:
	get: return _gems
	set(value): _set_gems(value, not Engine.is_editor_hint())

# ---------- Layout ----------
@export var stretch_texture: bool = true:
	set(value):
		stretch_texture = value
		if is_node_ready():
			_apply_stretch()

# ---------- Pop animation ----------
@export_group("Pop animation")
@export var pop_start_scale: float = 0.6
@export var pop_duration: float = 0.35
@export var flash_strength: float = 1.8

# ---------- Auto hide ----------
@export_group("Auto hide")
@export var auto_hide: bool = true
@export var start_hidden: bool = true
@export var hide_delay: float = 3.0        # seconds with no new gem before hiding
@export var fade_in_duration: float = 0.15
@export var fade_out_duration: float = 0.6

# ---------- Testing (buttons in the Inspector) ----------
@export_group("Testing")
@export_group("Testing")
@export_tool_button("+1 gem") var btn_add: Callable = func(): _test_add()
@export_tool_button("-1 gem") var btn_remove: Callable = func(): _test_remove()
@export_tool_button("Fill all") var btn_fill: Callable = func(): _test_fill()
@export_tool_button("Reset") var btn_reset: Callable = func(): _test_reset()
@onready var frames: TextureProgressBar = $Frames

var _pop_tweens: Dictionary = {}
var _fade_tween: Tween
var _hide_timer: Timer


func _ready() -> void:
	_apply_stretch()
	_refresh(false)

	if Engine.is_editor_hint():
		return

	_hide_timer = Timer.new()
	_hide_timer.one_shot = true
	_hide_timer.timeout.connect(_fade_to.bind(0.0, fade_out_duration))
	add_child(_hide_timer)

	if auto_hide and start_hidden:
		frames.modulate.a = 0.0
		frames.hide()


# ---------- Core ----------
func _set_gems(value: int, animate: bool) -> void:
	value = maxi(value, 0)
	var gained := value > _gems
	_gems = value
	if not is_node_ready():
		return
	_refresh(animate)
	if gained:
		_on_gems_gained()


func _refresh(animate: bool) -> void:
	for piece: TextureProgressBar in frames.get_children():
		var was_filled := piece.value >= piece.max_value
		var is_filled := _gems >= piece.max_value
		piece.value = piece.max_value if is_filled else piece.min_value

		if animate and is_filled and not was_filled:
			_pop(piece)
		elif not animate:
			_reset_piece_visuals(piece)


func _apply_stretch() -> void:
	frames.nine_patch_stretch = stretch_texture
	for piece: TextureProgressBar in frames.get_children():
		piece.nine_patch_stretch = stretch_texture


# ---------- Pop ----------
func _pop(piece: TextureProgressBar) -> void:
	if _pop_tweens.has(piece) and _pop_tweens[piece].is_valid():
		_pop_tweens[piece].kill()

	piece.pivot_offset = piece.size / 2.0
	piece.scale = Vector2.ONE * pop_start_scale
	piece.modulate = Color(flash_strength, flash_strength, flash_strength, 0.0)

	var t := create_tween().set_parallel(true)
	t.tween_property(piece, "scale", Vector2.ONE, pop_duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(piece, "modulate:a", 1.0, pop_duration * 0.5)
	t.chain().tween_property(piece, "modulate", Color.WHITE, pop_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_pop_tweens[piece] = t


func _reset_piece_visuals(piece: TextureProgressBar) -> void:
	if _pop_tweens.has(piece) and _pop_tweens[piece].is_valid():
		_pop_tweens[piece].kill()
	piece.scale = Vector2.ONE
	piece.modulate = Color.WHITE


# ---------- Auto hide ----------
func _on_gems_gained() -> void:
	if Engine.is_editor_hint() or not auto_hide:
		return
	_fade_to(1.0, fade_in_duration)
	_hide_timer.start(hide_delay)   # restarts the countdown on every new gem


func _fade_to(alpha: float, duration: float) -> void:
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	if alpha > 0.0:
		frames.show()
	_fade_tween = create_tween()
	_fade_tween.tween_property(frames, "modulate:a", alpha, duration)
	if alpha <= 0.0:
		_fade_tween.tween_callback(frames.hide)


# ---------- Testing ----------
func _test_add() -> void:    _set_gems(_gems + 1, true)
func _test_remove() -> void: _set_gems(_gems - 1, false)
func _test_reset() -> void:  _set_gems(0, false)
func _test_fill() -> void:
	var top := 0
	for piece: TextureProgressBar in frames.get_children():
		top = maxi(top, int(piece.max_value))
	_set_gems(top, true)


# Keyboard shortcuts while playing (debug builds only): + / - change gem count
func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_EQUAL, KEY_KP_ADD:
				collected_gems += 1
			KEY_MINUS, KEY_KP_SUBTRACT:
				collected_gems -= 1
