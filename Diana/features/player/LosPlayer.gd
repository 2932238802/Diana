extends CharacterBody2D

@export var L_speed: float = 200.0

var target_position: Vector2 
func _ready() -> void:
	target_position = global_position

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("L_KEY_RIGHTCLICKED"):
		target_position = get_global_mouse_position()

	if global_position.distance_to(target_position) > 5:
		var direction = (target_position - global_position).normalized()
		velocity = direction * L_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
