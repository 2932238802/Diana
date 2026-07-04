extends Camera2D

@export var L_edgeMargin: float = 50.0
@export var L_camSpeed: float = 800.0

# 只要变量初始化 需要访问其他节点 就用 onready
@onready var L_player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	# 空格归位（已完成）
	if Input.is_action_just_pressed("L_KEY_FOCUS_PLAYER"):
		global_position = L_player.global_position
	
	var pos = get_viewport().get_mouse_position()
	var size = get_viewport().get_visible_rect().size
	var dir = Vector2.ZERO
	# 左边
	if pos.x < L_edgeMargin: 
		dir.x = -1
	# 右边
	if pos.x > size.x - L_edgeMargin: 
		dir.x = 1
	# 上面
	if pos.y < L_edgeMargin: 
		dir.y = -1
	# 下面
	if pos.y > size.y - L_edgeMargin:
		dir.y = 1
	
	global_position += dir * L_camSpeed * delta
