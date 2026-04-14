extends Node
class_name LevelManager

# 5个关卡配置
# 每个关卡包含：路径点、名称、敌人数量倍率、金币/生命奖励

const LEVELS: Array[Dictionary] = [
	{
		"name": "第 1 关 - 新手试炼",
		"enemy_mult": 1.0,
		"bonus_gold": 0,
		"bonus_lives": 0,
		"path": [
			Vector2(50, 360), Vector2(200, 360), Vector2(200, 200),
			Vector2(500, 200), Vector2(500, 400), Vector2(800, 400),
			Vector2(800, 300), Vector2(1100, 300), Vector2(1400, 300),
		],
	},
	{
		"name": "第 2 关 - 曲折山路",
		"enemy_mult": 1.2,
		"bonus_gold": 50,
		"bonus_lives": 0,
		"path": [
			Vector2(50, 150), Vector2(300, 150), Vector2(300, 500),
			Vector2(600, 500), Vector2(600, 150), Vector2(900, 150),
			Vector2(900, 500), Vector2(1200, 500), Vector2(1200, 300),
		],
	},
	{
		"name": "第 3 关 - 双重考验",
		"enemy_mult": 1.5,
		"bonus_gold": 80,
		"bonus_lives": 5,
		"path": [
			Vector2(50, 600), Vector2(200, 600), Vector2(200, 100),
			Vector2(500, 100), Vector2(500, 600), Vector2(800, 600),
			Vector2(800, 200), Vector2(1100, 200), Vector2(1100, 500),
			Vector2(1400, 500),
		],
	},
	{
		"name": "第 4 关 - 迷失森林",
		"enemy_mult": 1.8,
		"bonus_gold": 100,
		"bonus_lives": 5,
		"path": [
			Vector2(50, 300), Vector2(150, 300), Vector2(150, 550),
			Vector2(350, 550), Vector2(350, 200), Vector2(550, 200),
			Vector2(550, 500), Vector2(750, 500), Vector2(750, 150),
			Vector2(950, 150), Vector2(950, 450), Vector2(1150, 450),
			Vector2(1150, 300), Vector2(1400, 300),
		],
	},
	{
		"name": "第 5 关 - 王者之路",
		"enemy_mult": 2.2,
		"bonus_gold": 150,
		"bonus_lives": 10,
		"path": [
			Vector2(50, 600), Vector2(150, 600), Vector2(150, 200),
			Vector2(350, 200), Vector2(350, 500), Vector2(500, 500),
			Vector2(500, 100), Vector2(700, 100), Vector2(700, 550),
			Vector2(900, 550), Vector2(900, 250), Vector2(1100, 250),
			Vector2(1100, 500), Vector2(1300, 500), Vector2(1300, 350),
			Vector2(1450, 350),
		],
	},
]

static func get_level(level_index: int) -> Dictionary:
	if level_index < 0 or level_index >= LEVELS.size():
		return LEVELS[0]
	return LEVELS[level_index]

static func get_total_levels() -> int:
	return LEVELS.size()

static func get_level_path(level_index: int) -> Array[Vector2]:
	return get_level(level_index)["path"]
