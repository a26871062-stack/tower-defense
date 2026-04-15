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
			Vector2(50, 440), Vector2(200, 440), Vector2(200, 280),
			Vector2(500, 280), Vector2(500, 480), Vector2(800, 480),
			Vector2(800, 380), Vector2(1100, 380), Vector2(1400, 380),
		],
	},
	{
		"name": "第 2 关 - 曲折山路",
		"enemy_mult": 1.2,
		"bonus_gold": 50,
		"bonus_lives": 0,
		"path": [
			Vector2(50, 230), Vector2(300, 230), Vector2(300, 580),
			Vector2(600, 580), Vector2(600, 230), Vector2(900, 230),
			Vector2(900, 580), Vector2(1200, 580), Vector2(1200, 380),
		],
	},
	{
		"name": "第 3 关 - 双重考验",
		"enemy_mult": 1.5,
		"bonus_gold": 80,
		"bonus_lives": 5,
		"path": [
			Vector2(50, 680), Vector2(200, 680), Vector2(200, 180),
			Vector2(500, 180), Vector2(500, 680), Vector2(800, 680),
			Vector2(800, 280), Vector2(1100, 280), Vector2(1100, 580),
			Vector2(1400, 580),
		],
	},
	{
		"name": "第 4 关 - 迷失森林",
		"enemy_mult": 1.8,
		"bonus_gold": 100,
		"bonus_lives": 5,
		"path": [
			Vector2(50, 380), Vector2(150, 380), Vector2(150, 630),
			Vector2(350, 630), Vector2(350, 280), Vector2(550, 280),
			Vector2(550, 580), Vector2(750, 580), Vector2(750, 230),
			Vector2(950, 230), Vector2(950, 530), Vector2(1150, 530),
			Vector2(1150, 380), Vector2(1400, 380),
		],
	},
	{
		"name": "第 5 关 - 王者之路",
		"enemy_mult": 2.2,
		"bonus_gold": 150,
		"bonus_lives": 10,
		"path": [
			Vector2(50, 680), Vector2(150, 680), Vector2(150, 280),
			Vector2(350, 280), Vector2(350, 580), Vector2(500, 580),
			Vector2(500, 180), Vector2(700, 180), Vector2(700, 630),
			Vector2(900, 630), Vector2(900, 330), Vector2(1100, 330),
			Vector2(1100, 580), Vector2(1300, 580), Vector2(1300, 430),
			Vector2(1450, 430),
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
