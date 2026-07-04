extends Node

# 参数
var max_health: float = 100.0
var current_health: float = 100.0
var max_energy: float = 100.0
var current_energy: float = 100.0

# 更改状态栏
func alter_health(amount: float) -> void:
	current_health = clamp(current_health + amount, 0.0, max_health)
	LosRouter.ls_health_changed.emit(current_health,max_health)

# 更改精力
func alter_energy(amount: float) -> void:
	current_energy = clamp(current_energy + amount, 0.0, max_energy)
	LosRouter.ls_energy_changed.emit(current_energy,max_energy)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
