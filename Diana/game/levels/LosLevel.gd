extends Node2D

@export var L_enemyScene:PackedScene
var L_enemyArray:Array = []


# 生产一个指定的怪物
func addEnemy(config:Dictionary, pos: Vector2) -> void:
	var LosLuaInstance = Engine.get_singleton("LosLuaInstance")
	var enemy = L_enemyScene.instantiate()
	add_child(enemy)
	enemy.global_position = pos
	enemy.initConfig(config)
	L_enemyArray.append(enemy)



# 敌人死亡 观察状态
func _onEnemyDied(enemy_did:int,cur_level:int) -> void:
	pass
	


# 准备阶段
func _ready() -> void:
	LosRouter.ls_enemy_died.connect(_onEnemyDied)
	
	var LosLuaInstance = Engine.get_singleton("LosLuaInstance")
	var config_1 = LosLuaInstance.lLuaLoadEnemy("enemy_1")
	var config_2 = LosLuaInstance.lLuaLoadEnemy("enemy_2")
	
	for i in range(5):
		var pos = Vector2(randf_range(-1220, 1220), randf_range(-920, 920))
		addEnemy(config_1, pos)
		
	for i in range(2):
		var pos = Vector2(randf_range(-1220, 1220), randf_range(-920, 920))
		addEnemy(config_2, pos)
	

func _process(delta: float) -> void:
	pass
	
	
	
	
	
