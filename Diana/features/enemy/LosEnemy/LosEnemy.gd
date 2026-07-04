extends CharacterBody2D

@export var L_MAX_HEALTH: float = 30.0
# 离玩家这么近就停下
@export var L_stopDistance: float = 200.0   

# 当前血量
var L_currentHealth: float = 30.0



# 移动速度
@export var L_speed: float = 100.0
@onready var L_player = get_tree().get_first_node_in_group("player")



# 修改状态
func alterHealth(amount: float) -> void:
	L_currentHealth += amount
	if L_currentHealth <= 0:
		die()
		

# 去世
func die() -> void:
	queue_free()


func _physics_process(delta: float) -> void:
	if L_player == null:
		return
		
	var distance = global_position.distance_to(L_player.global_position)
	if distance > L_stopDistance:
		var direction = (L_player.global_position - global_position).normalized()
		velocity = direction * L_speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()


func _ready() -> void:
	L_currentHealth = L_MAX_HEALTH
