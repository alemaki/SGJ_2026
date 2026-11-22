extends CharacterBody2D
class_name Player

# Movement settings
@export var speed: float = 50.0
@export var acceleration: float = 120.0
@export var friction: float = 300.0

# Illumination settings
@export var illuminate_cooldown: float = 1.5
@export var illuminate_timer_max: float = 120.0 # expected in seconds

const RING_TEXTURE_SIZE := 256
const RING_MIN_SCALE := 0.01

var _illuminate_cooldown_left: float = 0.0
var _illuminate_timer: float = illuminate_timer_max

@export var light_radius: float = 750.0
@export var light_energy: float = 1
@export var light_grow_duration: float = 1.1
@export var light_shrink_duration: float = 0.4
@export var light_color: Color = Color(1.0, 0.95, 0.7)
@export_range(0.01, 1.0, 0.01) var light_core_brightness: float = 0.5  # peak at the center (1.0 = full white)
@export_range(0.0, 1.0, 0.01) var light_falloff_softness: float = 0.5  # 0 = linear, 1 = very soft, wide glow

@export var animation_player: AnimatedSprite2D = null
@export var obsession_bar: ObsessionBar = null
@export var score_tracker: ScoreTracker = null
@export var light_progress: LightProgress = null

const LIGHT_TEXTURE_SIZE := 256
const LIGHT_MIN_SCALE := 0.01

var _light_texture: GradientTexture2D
var _light: PointLight2D
var _light_tween: Tween
var _light_on := false
var _is_input_allowed := true;

@onready var interactable_sensor: InteractableSensor = $InteractableSensor
@onready var highlighter: Highlighter = $Highlighter

var last_dir = ""


signal player_death(final_score)

func _ready() -> void:
	obsession_bar.resume_progress()
	interactable_sensor.on_interaction_performed.connect(_play_interaction_animation)
	light_progress.set_progress(_illuminate_timer, illuminate_timer_max)

func _handle_animations(input_dir: Vector2) -> void:
	if velocity == Vector2.ZERO:
		animation_player.play("idle")
		AudioManager.getInstance().pauseAudio("walking")
	else:
		AudioManager.getInstance().playAndLoadAudio("walking","res://assets/audio/sfx/walking-gravel.mp3","Echo",0.0,true)
		if input_dir.x < 0:
			animation_player.play("left")
			last_dir = "left"
		elif input_dir.x > 0:
			animation_player.play("right")
			last_dir = "right"
		elif input_dir.y < 0:
			animation_player.play("up")
			last_dir = "up"
		elif input_dir.y > 0:
			animation_player.play("down")
			last_dir = "down"



func _physics_process(delta: float) -> void:
	if not _is_input_allowed:
		return;

	# Handling movement
	var input_dir := Vector2(
		Input.get_axis("ui_left_device_0", "ui_right_device_0"),
		Input.get_axis("ui_up_device_0", "ui_down_device_0")
	)

	input_dir = input_dir.limit_length(1.0)

	if input_dir != Vector2.ZERO:
		if velocity.dot(input_dir) <= 0:
			velocity = velocity.move_toward(input_dir * speed, friction * delta)
		velocity = velocity.move_toward(input_dir * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()

	_handle_animations(input_dir)

	# Hangling Illuminate cooldown
	_illuminate_cooldown_left = maxf(_illuminate_cooldown_left - delta, 0.0)

	if _light_on && _illuminate_timer > 0:
		_illuminate_timer -= delta
		light_progress.set_progress(_illuminate_timer, illuminate_timer_max)
	if _illuminate_timer <= 0 and _light_on:
		_toggle_light()

	if Input.is_action_just_pressed("ui_back_device_0") and _illuminate_cooldown_left == 0.0 and _illuminate_timer > 0:
		_toggle_light()
		highlighter.toggle_highlighting()
		_illuminate_cooldown_left = illuminate_cooldown

	# Handle interaction
	if Input.is_action_just_pressed("ui_accept_device_0"):

		if interactable_sensor.request_interaction():
			# Play pick up animation or whatever
			pass


func _toggle_light() -> void:
	_light_on = not _light_on
	if _light_tween:
		_light_tween.kill()

	if _light_on:
		_grow_light()
	else:
		_shrink_light()


func _grow_light() -> void:
	if _light == null:
		_light = PointLight2D.new()
		_light.texture = _get_light_texture()
		_light.color = light_color
		_light.energy = 0.0
		_light.texture_scale = LIGHT_MIN_SCALE
		add_child(_light)

	# If reversing a shrink, only spend the time still needed
	var duration := light_grow_duration * (1.0 - _light_progress())

	_light_tween = _light.create_tween().set_parallel(true)
	_light_tween.tween_property(_light, "texture_scale", _light_target_scale(), duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_light_tween.tween_property(_light, "energy", light_energy, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _shrink_light() -> void:
	if _light == null:
		return

	var duration := light_shrink_duration * _light_progress()

	_light_tween = _light.create_tween().set_parallel(true)
	_light_tween.tween_property(_light, "texture_scale", LIGHT_MIN_SCALE, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_light_tween.tween_property(_light, "energy", 0.0, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_light_tween.chain().tween_callback(_free_light)


func _free_light() -> void:
	if _light:
		_light.queue_free()
		_light = null


func _light_target_scale() -> float:
	return light_radius * 2.0 / LIGHT_TEXTURE_SIZE


# 0.0 = fully shrunk, 1.0 = fully grown
func _light_progress() -> float:
	if _light == null:
		return 0.0
	return clampf(
		inverse_lerp(LIGHT_MIN_SCALE, _light_target_scale(), _light.texture_scale),
		0.0, 1.0)


# Current light radius in pixels (0 when off)
func get_light_radius() -> float:
	if _light == null:
		return 0.0
	return _light.texture_scale * LIGHT_TEXTURE_SIZE * 0.5


func _get_light_texture() -> GradientTexture2D:
	if _light_texture == null:
		var gradient := Gradient.new()
		var steps := 32
		var offsets := PackedFloat32Array()
		var colors := PackedColorArray()

		# Smooth bell-like curve sampled into gradient stops
		var power := lerpf(1.0, 3.0, light_falloff_softness)
		for i in steps + 1:
			var t := float(i) / steps
			var a := light_core_brightness * pow(1.0 - smoothstep(0, 1, t), power)
			offsets.append(t)
			colors.append(Color(1, 1, 1, a))
		# Make sure the edge is fully transparent
		colors[steps] = Color(1, 1, 1, 0)

		gradient.offsets = offsets
		gradient.colors = colors

		_light_texture = GradientTexture2D.new()
		_light_texture.gradient = gradient
		_light_texture.fill = GradientTexture2D.FILL_RADIAL
		_light_texture.fill_from = Vector2(0.5, 0.5)
		_light_texture.fill_to = Vector2(1.0, 0.5)
		_light_texture.width = LIGHT_TEXTURE_SIZE
		_light_texture.height = LIGHT_TEXTURE_SIZE
	return _light_texture

func _play_interaction_animation(animation_name: StringName, _interactable: Interactable):
	# Little hack on the fact that the players will try to get as close to the gem
	# as possible - meaning the last direction of the player will be the last direction used.
	# This is because the dot algorithm did not work.
	animation_name = last_dir + "_dig"
	#var gem_pos = _interactable.get_global_position()
	#var direction = gem_pos - global_position
	#if Vector2.RIGHT.dot(direction) > 0:
		#animation_name = "right_dig"
	#elif Vector2.LEFT.dot(direction) > 0:
		#animation_name = "left_dig"
	#if Vector2.UP.dot(direction) > 0:
		#animation_name = "up_dig"
	#elif Vector2.DOWN.dot(direction) > 0:
		#animation_name = "down_dig"

	if animation_player.sprite_frames.has_animation(animation_name):
		_is_input_allowed = false
		animation_player.animation_finished.connect(_release_input)
		animation_player.play(animation_name)

func _play_animation(animation_name: StringName):
	if animation_player.sprite_frames.has_animation(animation_name):
		_is_input_allowed = false
		animation_player.animation_finished.connect(_release_input)
		animation_player.play(animation_name)

func _release_input():
	animation_player.animation_finished.disconnect(_release_input)
	_is_input_allowed = true;


func _on_obsession_bar_obsession_filled() -> void:
	player_death.emit(score_tracker.current_score)
