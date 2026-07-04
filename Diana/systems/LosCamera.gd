extends Camera2D

@export var edge_margin: float = 50.0
@export var cam_speed: float = 800.0

# 只要变量初始化 需要访问其他节点 就用 onready
@onready var player = get_node("../Player")

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	# 空格归位（已完成）
	if Input.is_action_just_pressed("L_KEY_FOCUS_PLAYER"):
		global_position = player.global_position
	
	var pos = get_viewport().get_mouse_position()
	var size = get_viewport().get_visible_rect().size
	var dir = Vector2.ZERO
	# 左边
	if pos.x < edge_margin: 
		dir.x = -1
	# 右边
	if pos.x > size.x - edge_margin: 
		dir.x = 1
	# 上面
	if pos.y < edge_margin: 
		dir.y = -1
	# 下面
	if pos.y > size.y - edge_margin:
		dir.y = 1
	
	global_position += dir * cam_speed * delta
