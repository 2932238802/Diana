extends Node2D

@export var L_enemyScene:PackedScene
var L_enemyArray:Array = []

@onready var L_tilemap = $TileMapLayer
const WALL_TILE   = Vector2i(4, 3) 
const GROUND_TILE = Vector2i(1, 4) 
const TILE_SIZE = 16
const HEIGHT_SIZE = 90
const WIDE_SIZE = 120


# 生成基础 地图
func generateBaseMap(width: int, height: int, origin: Vector2i) -> void:
	for x in range(width):
		for y in range(height):
			var cell = origin + Vector2i(x, y)
			if x == 0 or x == width - 1 or y == 0 or y == height - 1:
				L_tilemap.set_cell(cell, 0, WALL_TILE)     
			else:
				L_tilemap.set_cell(cell, 0, GROUND_TILE)    
				
				
				
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
	generateBaseMap(WIDE_SIZE,HEIGHT_SIZE,Vector2i(-WIDE_SIZE / 2, -HEIGHT_SIZE / 2))
	var LosLuaInstance = Engine.get_singleton("LosLuaInstance")
	var config_1 = LosLuaInstance.lLuaLoadEnemy("enemy_1")
	var config_2 = LosLuaInstance.lLuaLoadEnemy("enemy_2")
	var halfWide = _beginFloorIndex(WIDE_SIZE)
	var halfHeight = _beginFloorIndex(HEIGHT_SIZE)
	
	for i in range(5):
		var pos = Vector2(randf_range(-1 * halfWide, halfWide), randf_range(-1 * halfHeight, halfHeight))
		addEnemy(config_1, pos)
		
	for i in range(2):
		var pos = Vector2(randf_range(-1 *halfWide, halfWide), randf_range(-1 *halfHeight, halfHeight))
		addEnemy(config_2, pos)
	

func _beginFloorIndex(size : int):
	return (size * TILE_SIZE - 2 * TILE_SIZE) / 2.0


func _process(delta: float) -> void:
	pass
		
	
	
	
	
