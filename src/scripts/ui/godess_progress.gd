extends Control
class_name Vitraj

@export var collected_gems: int = 0:
	set(value):
		value = maxi(value, 0)
		var gained := value > collected_gems
		collected_gems = value

		if is_node_ready():
			_refresh(true)
			if gained:
				_on_gems_gained()

@export var stretch_texture: bool = true

# ---------- Sprite sheet ----------
@export_group("Sprite sheet")
@export var sheet: Texture2D                       # Goddess_progress.png
@export var frame_size: Vector2i = Vector2i(163, 200)
@export var first_frame: int = 0                   # sheet frame used by the first child
@export var under_frame: int = -1                  # frame for Frames' background (-1 = leave as is)

# ---------- Colours ----------
@export_group("Random colour")
@export_range(0.0, 1.0) var min_saturation: float = 0.5
@export_range(0.0, 1.0) var max_saturation: float = 0.9
@export_range(0.0, 1.0) var min_brightness: float = 0.8
@export_range(0.0, 1.0) var max_brightness: float = 1.0

# ---------- Pop animation ----------
@export_group("Pop animation")
@export var pop_start_scale: float = 0.6
@export var pop_duration: float = 0.35
@export var flash_strength: float = 1.8

# ---------- Auto hide ----------
@export_group("Auto hide")
@export var auto_hide: bool = true
@export var start_hidden: bool = true
@export var hide_delay: float = 3.0
@export var fade_in_duration: float = 0.15
@export var fade_out_duration: float = 0.6

@onready var frames: TextureProgressBar = $Frames

var _pop_tweens: Dictionary = {}
var _fade_tween: Tween
var _hide_timer: Timer


func _ready() -> void:
	_setup_pieces()
	_refresh(false)

	GlobalEvents.gem_collected.connect(on_gem_collected)
	
	_hide_timer = Timer.new()
	_hide_timer.one_shot = true
	_hide_timer.timeout.connect(_fade_to.bind(0.0, fade_out_duration))
	add_child(_hide_timer)

	if auto_hide and start_hidden:
		frames.modulate.a = 0.0
		frames.hide()


func on_gem_collected(score: int) -> void:
	AudioManager.getInstance().playAndLoadAudio("mural", "res://assets/audio/sfx/glass-restore.mp3", "Master", 0.0, false)
	collected_gems = collected_gems + score / 20


# First child unlocks at 1 gem, second at 2, ... last at child count.
# Each child also gets its own frame from the sprite sheet.
func _setup_pieces() -> void:
	frames.nine_patch_stretch = stretch_texture

	var frame_count := 0
	if sheet:
		frame_count = sheet.get_width() / frame_size.x
		if under_frame >= 0:
			if under_frame < frame_count:
				frames.texture_under = _make_frame(under_frame)
			else:
				push_warning("Vitraj: under_frame %d is outside the sheet (%d frames)" % [under_frame, frame_count])

	var pieces := frames.get_children()
	for i in pieces.size():
		var piece := pieces[i] as TextureProgressBar
		if piece == null:
			continue

		# Gem thresholds
		piece.nine_patch_stretch = stretch_texture
		piece.step = 1.0
		piece.min_value = 0.0          # reset first so the new range is never invalid
		piece.max_value = i + 1
		piece.min_value = i
		piece.value = piece.min_value

		# Sprite sheet frame
		if sheet:
			var frame := first_frame + i
			if frame >= frame_count:
				push_warning("Vitraj: child %d wants frame %d but the sheet only has %d frames" % [i, frame, frame_count])
				continue
			piece.texture_progress = _make_frame(frame)


func _make_frame(index: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(index * frame_size.x, 0, frame_size.x, frame_size.y)
	return atlas


func get_total_pieces() -> int:
	return frames.get_child_count()


# ---------- Core ----------
func _refresh(animate: bool) -> void:
	for piece: TextureProgressBar in frames.get_children():
		var was_filled := piece.value >= piece.max_value
		var is_filled := collected_gems >= piece.max_value
		piece.value = piece.max_value if is_filled else piece.min_value

		if is_filled and not was_filled:
			var colour := _random_colour()
			if animate:
				_pop(piece, colour)
			else:
				_set_piece_visuals(piece, colour)
		elif not is_filled:
			_set_piece_visuals(piece, Color.WHITE)


func _random_colour() -> Color:
	return Color.from_hsv(
		randf(),
		randf_range(min_saturation, max_saturation),
		randf_range(min_brightness, max_brightness)
	)


# ---------- Pop ----------
func _pop(piece: TextureProgressBar, colour: Color) -> void:
	_kill_pop(piece)

	piece.pivot_offset = piece.size / 2.0
	piece.scale = Vector2.ONE * pop_start_scale
	var flash := Color(colour.r * flash_strength, colour.g * flash_strength, colour.b * flash_strength, 0.0)
	piece.modulate = flash

	var t := create_tween().set_parallel(true)
	t.tween_property(piece, "scale", Vector2.ONE, pop_duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(piece, "modulate:a", 1.0, pop_duration * 0.5)
	t.chain().tween_property(piece, "modulate", colour, pop_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_pop_tweens[piece] = t


func _set_piece_visuals(piece: TextureProgressBar, colour: Color) -> void:
	_kill_pop(piece)
	piece.scale = Vector2.ONE
	piece.modulate = colour


func _kill_pop(piece: TextureProgressBar) -> void:
	if _pop_tweens.has(piece) and _pop_tweens[piece].is_valid():
		_pop_tweens[piece].kill()


# ---------- Auto hide ----------
func _on_gems_gained() -> void:
	if not auto_hide:
		return

	_fade_to(1.0, fade_in_duration)
	_hide_timer.start(hide_delay)


func _fade_to(alpha: float, duration: float) -> void:
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	if alpha > 0.0:
		frames.show()
	_fade_tween = create_tween()
	_fade_tween.tween_property(frames, "modulate:a", alpha, duration)
	if alpha <= 0.0:
		_fade_tween.tween_callback(frames.hide)


# Debug keys while playing: + / - change gem count (not in exported builds)
func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_EQUAL, KEY_KP_ADD:
				collected_gems += 1
			KEY_MINUS, KEY_KP_SUBTRACT:
				collected_gems -= 1
