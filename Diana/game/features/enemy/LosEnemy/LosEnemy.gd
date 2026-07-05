extends CharacterBody2D

# mon_1 
# 基础小怪

@export var L_MAX_HEALTH: float = 30.0
# 离玩家这么近就停下
@export var L_stopDistance: float = 50.0   

@export var L_attackDamage:float = 5.0
@export var L_attackInterval:float = 1.0
var L_attackTimer: float = 0.0
@export var L_attackRange : float = 65.0

@onready var L_healthBar = $HealthBar
@onready var L_anim = $AnimatedSprite2D

# 当前血量
var L_currentHealth: float = 30.0
# 受伤的 id 
var L_hideToken:int = 0;


# 移动速度
@export var L_speed: float = 100.0
@onready var L_player = get_tree().get_first_node_in_group("player")



# 修改状态
func alterHealth(amount: float) -> void:
	L_currentHealth += amount
	L_healthBar.value = L_currentHealth / L_MAX_HEALTH * 100.0
#	可见
	L_healthBar.visible = true 
#	如果小于 0 就销毁
#	显示血条
	showHealthBar()
	if L_currentHealth <= 0:
		die()
	else:
#		体现受伤
		L_anim.play("hurt")
		
		
		
#	显示血条	
func showHealthBar() -> void:
	L_healthBar.visible = true
	L_hideToken += 1
	var lovalToken = L_hideToken
	await get_tree().create_timer(2.0).timeout
	if lovalToken == L_hideToken:
		L_healthBar.visible = false
		



# 攻击玩家
func attackPlayer() -> void :
	if L_player == null:
		return
	var distance = global_position.distance_to(L_player.global_position)
	if distance <= L_attackRange:
		LosPlayerState.alterHealth(-1.0 * L_attackDamage)



#  	去世
func die() -> void:
	L_anim.play("die")
	velocity = Vector2.ZERO
	await L_anim.animation_finished
	queue_free()



# 受伤动画结束
func onAnimationFinished() -> void:
	if L_anim.animation == "hurt":
		L_anim.play("walk")
	if L_anim.animation == "attack":
		L_anim.play("walk")



# 物理引擎移动
func _physics_process(delta: float) -> void:
	if L_player == null:
		return
		
	var distance = global_position.distance_to(L_player.global_position)
	if distance > L_stopDistance:
		var direction = (L_player.global_position - global_position).normalized()
		velocity = direction * L_speed
#		怪物转向
		if direction.x < 0:
			L_anim.flip_h = true 
		elif direction.x > 0:
			L_anim.flip_h = false 
	else:
		velocity = Vector2.ZERO
		if L_anim.animation != "hurt":
			if L_anim.animation != "attack":
				L_anim.play("attack")
		L_attackTimer += delta
		if L_attackTimer >= L_attackInterval:
			attackPlayer()
			L_attackTimer = 0.0
		
	move_and_slide()




func _ready() -> void:
	L_currentHealth = L_MAX_HEALTH
#	开局是走路状态
	L_anim.play("walk")
	L_anim.animation_finished.connect(onAnimationFinished)
	
	
	
	
	
