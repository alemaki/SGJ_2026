extends Control
class_name ScoreTracker

@export var score_label: Label = null
var current_score: int = 0

func _ready() -> void:
	GlobalEvents.gem_collected.connect(increase_score)

func _update_label_score() -> void:
	score_label.text = str(current_score)

func set_score(new_score: int) -> void:
	current_score = new_score
	clamp(current_score, 0, DHOPlayerData.MAX_SCORE)
	_update_label_score()

func increase_score(increased_value: int) -> void:
	current_score += increased_value
	clamp(current_score, 0, DHOPlayerData.MAX_SCORE)
	_update_label_score()
