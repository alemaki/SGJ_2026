extends Control

@export var bar: ObsessionBar = null
@export var timer: Timer = null

const SCORE_PER_TIME: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bar.resume_progress()

func _on_timer_timeout() -> void:
	bar.increase_current_score(SCORE_PER_TIME)
