extends Control

@export var logarithmic_bar: ObsessionBar = null
@export var linear_bar: ObsessionBar = null
@export var exponential_bar: ObsessionBar = null

@export var timer: Timer = null

const SCORE_PER_TIME: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logarithmic_bar.scaling_type = ObsessionBar.PROGRESS_SCALING.LOGARITHMIC
	logarithmic_bar.resume_progress()

	linear_bar.scaling_type = ObsessionBar.PROGRESS_SCALING.LINEAR
	linear_bar.resume_progress()

	exponential_bar.scaling_type = ObsessionBar.PROGRESS_SCALING.EXPONENTIAL
	exponential_bar.resume_progress()

func _on_timer_timeout() -> void:
	logarithmic_bar.increase_current_score(SCORE_PER_TIME)
	linear_bar.increase_current_score(SCORE_PER_TIME)
	exponential_bar.increase_current_score(SCORE_PER_TIME)
