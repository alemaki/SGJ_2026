extends CharacterBody2D


@export var speed: float = 200.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

func _physics_process(delta: float) -> void:

	var input_dir := Vector2(
		Input.get_axis("ui_left_device_0", "ui_right_device_0"),
		Input.get_axis("ui_up_device_0", "ui_down_device_0")
	)

	input_dir = input_dir.limit_length(1.0)

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
