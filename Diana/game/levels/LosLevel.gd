extends Node2D

var LOS_mapMgr = LosMapGenerator.new()

@onready var L_tilemap = $TileMapLayer
@onready var L_enemySpawner = $LosEnemySpawner

const WALL_TILE   = Vector2i(4, 3) 
const GROUND_TILE = Vector2i(1, 4) 
const TILE_SIZE = 16
const HEIGHT_SIZE = 90
const WIDE_SIZE = 120


# 敌人死亡 观察状态
func _onEnemyDied(enemy_did:int,cur_level:int) -> void:
	pass
	


# 准备阶段
func _ready() -> void:
	LosRouter.ls_enemy_died.connect(_onEnemyDied)
	LOS_mapMgr.generateBaseMap(L_tilemap, WIDE_SIZE, HEIGHT_SIZE, Vector2i(-WIDE_SIZE/2, -HEIGHT_SIZE/2))
	var LosLuaInstance = Engine.get_singleton("LosLuaInstance")
	var config_1 = LosLuaInstance.lLuaLoadEnemy("enemy_1")
	var config_2 = LosLuaInstance.lLuaLoadEnemy("enemy_2")
	var halfWide = _beginFloorIndex(WIDE_SIZE)
	var halfHeight = _beginFloorIndex(HEIGHT_SIZE)
	for i in range(5):
		var pos = Vector2(randf_range(-1 * halfWide, halfWide), randf_range(-1 * halfHeight, halfHeight))
		L_enemySpawner.addEnemy(config_1, pos)
	for i in range(2):
		var pos = Vector2(randf_range(-1 *halfWide, halfWide), randf_range(-1 *halfHeight, halfHeight))
		L_enemySpawner.addEnemy(config_2, pos)
	


func _beginFloorIndex(size : int):
	return (size * TILE_SIZE - 2 * TILE_SIZE) / 2.0



func _process(delta: float) -> void:
	pass
