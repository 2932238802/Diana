class_name LosEnemySpawner
extends Node

@export var L_enemyScene: PackedScene
var L_enemyArray: Array = []

func addEnemy(config: Dictionary, pos: Vector2) -> void:
	var enemy = L_enemyScene.instantiate()
	add_child(enemy)               
	enemy.global_position = pos
	enemy.initConfig(config)
	L_enemyArray.append(enemy)

func spawnByEnemyId(enemy_id: String, count: int, area: Rect2) -> void:
	var lua = Engine.get_singleton("LosLuaInstance")
	var config = lua.lLuaLoadEnemy(enemy_id)
	for i in range(count):
		var pos = Vector2(
			randf_range(area.position.x, area.end.x),
			randf_range(area.position.y, area.end.y)
		)
		addEnemy(config, pos)
