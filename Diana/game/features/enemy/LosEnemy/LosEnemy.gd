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
@export var L_discoverDistance : float = 300.0
@export var L_attackType: int = 0  						# 0 是近战 1 是远程射击 2 远程祈祷坠落

# 当前血量
var L_currentHealth: float = 30.0
# 受伤的 id 
var L_hideToken:int = 0
# 是否受伤 和 否死亡
var L_hurt:bool = false
var L_died:bool = false
# 弹幕
var L_bulletScene: PackedScene = null

@onready var L_healthBar = $HealthBar
@onready var L_anim = $AnimatedSprite2D



# 移动速度
@export var L_speed: float = 100.0
@onready var L_player = get_tree().get_first_node_in_group("player")


# 载入属性
func initConfig(config:Dictionary) -> void:
	L_MAX_HEALTH = config.get("health",L_MAX_HEALTH)
	L_currentHealth = L_MAX_HEALTH
	L_attackDamage = config.get("attack",L_attackDamage)
	L_speed = config.get("speed",L_speed)
	L_stopDistance = config.get("stop_distance",L_stopDistance)
	L_attackRange = config.get("attack_range",L_attackRange)
	L_discoverDistance = config.get("discover_distance",L_discoverDistance)
	L_attackType = config.get("attack_type",L_attackType)
	var bulletPath = config.get("bullet_scene","")
	if bulletPath != "":
		print("[DEBUG] LosEnemy initConfig bulletPath: ",bulletPath)
		L_bulletScene = load(bulletPath)
		
	var framesPath = config.get("sprite_frames", "")
	if framesPath != "":
		L_anim.sprite_frames = load(framesPath)
		L_anim.play("idle") 



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
		L_died = true
		die()
	else:
#		体现受伤
		L_anim.play("hurt")
		L_hurt = true
		
		
		
#	显示血条	
func showHealthBar() -> void:
	L_healthBar.visible = true
	L_hideToken += 1
	var lovalToken = L_hideToken
	await get_tree().create_timer(2.0).timeout
	if lovalToken == L_hideToken:
		L_healthBar.visible = false
		



# 近战
func doMelee() -> void :
	if L_player == null:
		return
	var distance = global_position.distance_to(L_player.global_position)
	if distance <= L_attackRange:
		LosPlayerState.alterHealth(-1.0 * L_attackDamage)



# 射击
func doShoot() -> void:
	if L_player == null:
		return
	if L_bulletScene == null:
		return
	var bullet = L_bulletScene.instantiate()
	get_parent().add_child(bullet)                	# 挂到 Level
	bullet.global_position = global_position        # 从敌人位置出发
	bullet.L_direction = (L_player.global_position - global_position).normalized()  # 朝玩家
	bullet.L_damage = L_attackDamage               	# 初始化 伤害



# 攻击 根据 攻击模式的不一样
func doAttack() -> void:
	if L_attackType == 0:
		doMelee()
	elif L_attackType == 1:
		doShoot()



#  	去世
func die() -> void:
	L_anim.play("die")
	velocity = Vector2.ZERO
	await L_anim.animation_finished
	queue_free()



# 受伤动画结束
func onAnimationFinished() -> void:
	if L_died:         
		return
	if L_anim.animation == "hurt":
		L_anim.play("walk")
	if L_anim.animation == "attack":
		L_anim.play("walk")



# 物理引擎移动
func _physics_process(delta: float) -> void:
	if L_player == null or L_died == true:
		return
	var distance = global_position.distance_to(L_player.global_position)
	# 进入侦查范围 或 被激怒 就是警觉状态
	var is_aware = (distance <= L_discoverDistance) or L_hurt
	# 不警觉  待机
	if not is_aware:
		velocity = Vector2.ZERO
		if L_anim.animation != "hurt":
			L_anim.play("idle")
		move_and_slide()
		return
	# 警觉 且 还没到攻击距离  追击
	if distance > L_stopDistance:                  
		var direction = (L_player.global_position - global_position).normalized()
		velocity = direction * L_speed
		if direction.x < 0:
			L_anim.flip_h = true
		elif direction.x > 0:
			L_anim.flip_h = false
		if L_anim.animation != "hurt":
			L_anim.play("walk")
		move_and_slide()
		return

	# 警觉 且 够近了  停下攻击
	velocity = Vector2.ZERO
	if L_anim.animation != "hurt" and L_anim.animation != "attack":
		L_anim.play("attack")
	L_attackTimer += delta
	if L_attackTimer >= L_attackInterval:
		doAttack()
		L_attackTimer = 0.0
	move_and_slide()



# 初始化
func _ready() -> void:
	L_currentHealth = L_MAX_HEALTH
#	开局是走路状态
	L_anim.play("idle")
	L_anim.animation_finished.connect(onAnimationFinished)
	
	
	
