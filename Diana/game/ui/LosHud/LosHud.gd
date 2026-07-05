extends CanvasLayer

@onready var L_hpBar = $Panel/VBox/HPBar
@onready var L_hpLabel = $Panel/VBox/HPBar/HPLabel
@onready var L_energyBar = $Panel/VBox/EnergyBar
@onready var L_energyLabel = $Panel/VBox/EnergyBar/EnergyLabel
@onready var L_floorLevelLabel = $Panel/VBox/FloorLabel

# 槽函数
func _onHealthChanged(new_health: float, max_health: float) -> void:
	L_hpBar.value = new_health / max_health * 100.0
	L_hpLabel.text = str(new_health) + " / " + str(max_health)



# 状态改变
func _onEnergyChanged(new_energy: float,max_energy:float) -> void:
	L_energyBar.value = new_energy / max_energy * 100.0
	L_energyLabel.text = str(new_energy) + " / " + str(max_energy)
	


# 到指定楼层
func _onFloorLevelChanged(level: int) -> void:
	L_floorLevelLabel.text = str(level)
	
	
	
# 初始化
func _ready() -> void:
	LosRouter.ls_health_changed.connect(_onHealthChanged)
	LosRouter.ls_energy_changed.connect(_onEnergyChanged)
	LosRouter.ls_level_changed.connect(_onFloorLevelChanged)
	_onHealthChanged(LosPlayerState.L_currentHealth,LosPlayerState.L_maxHealth)
	_onEnergyChanged(LosPlayerState.L_currentEnergy,LosPlayerState.L_maxEnergy)
	_onFloorLevelChanged(LosPlayerState.L_currentLevel)
