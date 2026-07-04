extends CanvasLayer

@onready var hp_bar = $Panel/VBox/HPBar
@onready var hp_label = $Panel/VBox/HPBar/HPLabel
@onready var energy_bar = $Panel/VBox/EnergyBar
@onready var energy_label = $Panel/VBox/EnergyBar/EnergyLabel

# 槽函数
func _onHealthChanged(new_health: float, max_health: float) -> void:
	hp_bar.value = new_health / max_health * 100.0
	hp_label.text = str(new_health) + " / " + str(max_health)
	
func _onEnergyChanged(new_energy: float,max_energy:float) -> void:
	energy_bar.value = new_energy / max_energy * 100.0
	energy_label.text = str(new_energy) + " / " + str(max_energy)
	
	
# 初始化
func _ready() -> void:
	LosRouter.ls_health_changed.connect(_onHealthChanged)
	LosRouter.ls_energy_changed.connect(_onEnergyChanged)
	_onHealthChanged(LosPlayerState.current_health,LosPlayerState.max_health)
	_onEnergyChanged(LosPlayerState.current_energy,LosPlayerState.max_energy)
