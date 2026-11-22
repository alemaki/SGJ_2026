extends Control
class_name ObsessionBar

@export var bar: TextureProgressBar = null

enum PROGRESS_SCALING {LOGARITHMIC, LINEAR, EXPONENTIAL};
@export var scaling_type: PROGRESS_SCALING = PROGRESS_SCALING.LOGARITHMIC

var current_progress: float = 0.0
# Current score needed because of the progression function.
var current_score: int = 0
var pause_timer: bool = true;

const MAX_PROGRESS: float = 100.0
@export var exponent_constant: float = 1.05
@export var logarithmic_base: float = 1.5
@export var score_conversion_scale: float = 1.0
@export var min_obsession_progress: float = 1.0

signal obsession_filled

func _logaritmic_scaling(score: float) -> float:
	return log(score) / log(logarithmic_base)

func _linear_scaling(score: float) -> float:
	return score

func _exponential_scaling(score: float) -> float:
	return score ** exponent_constant

func set_progress(new_progress: float) -> void:
	current_progress = new_progress
	clamp(current_progress, 0.0, MAX_PROGRESS)

func decrease_progress(decrease_value: float) -> void:
	current_progress -= decrease_value;
	clamp(current_progress, 0.0, MAX_PROGRESS)

func set_current_score(new_score: int) -> void:
	current_score = new_score

func increase_current_score(increase: int) -> void:
	current_score += increase

func pause_progress() -> void:
	pause_timer = true

func resume_progress() -> void:
	pause_timer = false

func set_progressing_enabled(new_enabled: bool) -> void:
	pause_timer = new_enabled

func scale(passed_time: float) -> float:
	var scaling_constant: float = 0.0
	var converted_score: float = max(current_score, min_obsession_progress) / score_conversion_scale
	match scaling_type:
		PROGRESS_SCALING.LOGARITHMIC:
			scaling_constant = _logaritmic_scaling(converted_score)
		PROGRESS_SCALING.LINEAR:
			scaling_constant = _linear_scaling(converted_score)
		PROGRESS_SCALING.EXPONENTIAL:
			scaling_constant = _exponential_scaling(converted_score)
	var final_scaling = scaling_constant * passed_time
	return final_scaling

func _ready() -> void:
	bar.value = 0

func _process(delta: float) -> void:
	if not pause_timer:
		bar.value += scale(delta)
		if is_equal_approx(bar.value, bar.max_value):
			obsession_filled.emit()
			pause_timer = true
		if is_equal_approx(bar.value, bar.max_value / 2):
			GlobalEvents.emit_signal("obsession_halfway")
