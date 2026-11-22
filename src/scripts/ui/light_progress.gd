extends Control
class_name LightProgress

@export var bar: TextureProgressBar = null

func set_progress(time_left: float, max_time: float) -> void:
	if time_left > 0:
		bar.value = time_left / max_time * 100 # percent conversion
	else:
		bar.value = 0
