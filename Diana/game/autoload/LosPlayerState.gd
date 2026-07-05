extends Node

# 参数
var L_maxHealth: float = 100.0
var L_currentHealth: float = 100.0
var L_maxEnergy: float = 100.0
var L_currentEnergy: float = 100.0
var L_currentLevel:int  = 1 				# 层

# 更改状态栏
func alterHealth(amount: float) -> void:
	L_currentHealth = clamp(L_currentHealth + amount, 0.0, L_maxHealth)
	LosRouter.ls_health_changed.emit(L_currentHealth,L_maxHealth)



# 更改精力
func alterEnergy(amount: float) -> void:
	L_currentEnergy = clamp(L_currentEnergy + amount, 0.0, L_maxEnergy)
	LosRouter.ls_energy_changed.emit(L_currentEnergy,L_maxEnergy)



# 到指定的楼层
func toTargetLevel(level :int) -> void:
	L_currentLevel = level
	LosRouter.ls_level_changed.emit(L_currentLevel)



# 到下一层
func toNextLevel() -> void:
	L_currentLevel +=1 
	LosRouter.ls_level_changed.emit(L_currentLevel)



func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
