extends CharacterBody2D

@export var L_speed: float = 400.0
@export var L_bulletScene: PackedScene
@export var L_fireRate: float = 0.15 

var L_fireTimer: float = 0.0  

# $AimLine = get_node("AimLine")           
@onready var aim_line = $AimLine        

var target_position: Vector2 

# 射击 函数
func shoot() -> void:
	var bullet = L_bulletScene.instantiate()
	bullet.global_position = global_position
	bullet.L_direction = (get_global_mouse_position() - global_position).normalized()
	get_parent().add_child(bullet)


# 加载
func _ready() -> void:
	target_position = global_position



# 物理移动
func _physics_process(delta: float) -> void:
	# 右键移动
	if Input.is_action_just_pressed("L_KEY_RIGHTCLICKED"):
		target_position = get_global_mouse_position()
	
	# 瞄准 + 射击
	if Input.is_action_pressed("L_KEY_AIM"):
		aim_line.visible = true
		aim_line.points = [Vector2.ZERO, get_local_mouse_position()]
#		如果按了 左键
		if Input.is_action_pressed("L_KEY_SHOOT"):
			L_fireTimer += delta
			if L_fireTimer >= L_fireRate:
				shoot()
				L_fireTimer = 0.0
		else:
			L_fireTimer = L_fireRate
	else:
		aim_line.visible = false
		
	if global_position.distance_to(target_position) > 5:
		velocity = (target_position - global_position).normalized() * L_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
