extends Node2D

@export var increase_timer: Timer = null
@export var score_control: ScoreTracker = null

@export var score_scale_increase: int = 1

func _on_timer_timeout() -> void:
	score_control.increase_score(score_scale_increase)
