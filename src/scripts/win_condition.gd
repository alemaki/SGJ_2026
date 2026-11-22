extends Node2D

@onready var win_condition_area: Area2D = $Area2D
@export var score_tracker: ScoreTracker = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(win_condition_area != null)
	win_condition_area.body_entered.connect(_on_body_entered)

func win() -> void:
	assert(score_tracker != null)
	DHOSceneManager.switch_to_save_score_scene(
			self.get_tree(),
			score_tracker.current_score,
			true
		)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		win()
