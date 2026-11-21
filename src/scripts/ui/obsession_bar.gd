extends Control
class_name ObsessionBar

#@export var bar: TextureProgressBar = null
@export var bar: ProgressBar = null

enum PROGRESS_SCALING {LOGARITHMIC, LINEAR, EXPONENTIAL};
@export var scaling_type: PROGRESS_SCALING = PROGRESS_SCALING.LOGARITHMIC

@export var max_scaling_value: float = 10.0

var current_progress: float = 0.0
# Current score needed because of the progression function.
var current_score: int = 0
var pause_timer: bool = true;

const MAX_PROGRESS: float = 100.0
const EXPONENT_CONSTANT: float = 1.2
const LOGARITHMIC_BASE: float = 2

func _logaritmic_scaling() -> float:
	return log(current_score) / log(LOGARITHMIC_BASE)

func _linear_scaling() -> float:
	return current_score

func _exponential_scaling() -> float:
	return current_score ** EXPONENT_CONSTANT

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
	match scaling_type:
		PROGRESS_SCALING.LOGARITHMIC:
			scaling_constant = _logaritmic_scaling()
		PROGRESS_SCALING.LINEAR:
			scaling_constant = _linear_scaling()
		PROGRESS_SCALING.EXPONENTIAL:
			scaling_constant = _exponential_scaling()
	var final_scaling = scaling_constant * passed_time
	#clamp(final_scaling, 0, max_scaling_value)
	return final_scaling

func _ready() -> void:
	bar.value = 0

func _process(delta: float) -> void:
	if not pause_timer:
		bar.value += scale(delta)
