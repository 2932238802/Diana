class_name LosMapGenerator
extends RefCounted

const WALL_TILE = Vector2i(4, 3)
const GROUND_TILE = Vector2i(1, 4)

func generateBaseMap(tilemap: TileMapLayer, width: int, height: int, origin: Vector2i) -> void:
	for x in range(width):
		for y in range(height):
			var cell = origin + Vector2i(x, y)
			if x == 0 or x == width-1 or y == 0 or y == height-1:
				tilemap.set_cell(cell, 0, WALL_TILE)
			else:
				tilemap.set_cell(cell, 0, GROUND_TILE)
