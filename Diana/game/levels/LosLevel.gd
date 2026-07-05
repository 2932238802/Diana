extends Node2D


# 敌人死亡 观察状态
func _onEnemyDied(enemy_did:int,cur_level:int) -> void:
	pass
	



# 准备阶段
func _ready() -> void:
	LosRouter.ls_enemy_died.connect(_onEnemyDied)
	var r = $LosLua.lLuaHello()
	$LosLua.lLuaLoadEnemy("enemy_1")
	print("Lua返回",r)



# 
func _process(delta: float) -> void:
	pass
