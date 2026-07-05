extends Camera2D

@export var L_edgeMargin: float = 50.0
@export var L_camSpeed: float = 800.0

@export var L_zoomSpeed: float = 0.1      
@export var L_zoomMin: float = 0.6       
@export var L_zoomMax: float = 2.0      

@export var L_limitLeft: int = -1240
@export var L_limitRight: int = 1240
@export var L_limitTop: int = -940
@export var L_limitBottom: int = 940

# 只要变量初始化 需要访问其他节点 就用 onready
@onready var L_player = get_tree().get_first_node_in_group("player")



func _ready() -> void:
	limit_left = L_limitLeft
	limit_right = L_limitRight
	limit_top = L_limitTop
	limit_bottom = L_limitBottom



# 输入事件
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			setZoomLevel(zoom.x + L_zoomSpeed)   
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			setZoomLevel(zoom.x - L_zoomSpeed)  



# 设置缩放，并限制在 [L_zoomMin, L_zoomMax] 范围内
func setZoomLevel(value: float) -> void:
	var z = clamp(value, L_zoomMin, L_zoomMax)
	zoom = Vector2(z, z)



func _process(delta: float) -> void:
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
