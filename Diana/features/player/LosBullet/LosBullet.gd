extends Area2D

# 子弹 （common）
# Area2D 能感知子弹穿过自己

@export var L_speed: float = 500.0
@export var L_MAX_DISTANCE: float = 800.0

var L_direction :Vector2 = Vector2.ZERO
var L_traveled : float = 0.0
var L_damage: float = 5.0



func _onBodyEntered(body) -> void:
	
	if body.is_in_group("enemy"):
		body.alterHealth(-1.0 * L_damage)
		
	queue_free()



func _ready() -> void:
	body_entered.connect(_onBodyEntered)



func _physics_process(delta: float) -> void:
#	飞行 + 累加举例
	var move = delta * L_direction * L_speed
	position += move
	L_traveled += move.length()
	if L_traveled > L_MAX_DISTANCE:
		queue_free()




	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
