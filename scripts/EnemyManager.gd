class_name EnemyManager

enum EnemyType { SKELETON, SLIME, BAT }

static var _enemy_scenes_loaded: bool = false
static var _enemy_scenes: Dictionary = {}

static var ENEMY_CONFIGS: Dictionary = {
	EnemyType.SKELETON: {"max_health": 100.0, "speed": 60.0, "reward": 10},
	EnemyType.SLIME: {"max_health": 60.0, "speed": 35.0, "reward": 5},
	EnemyType.BAT: {"max_health": 40.0, "speed": 100.0, "reward": 8},
}

static func _get_enemy_scenes() -> Dictionary:
	if not _enemy_scenes_loaded:
		_enemy_scenes = {
			EnemyType.SKELETON: load("res://scenes/enemy_skeleton.tscn"),
			EnemyType.SLIME: load("res://scenes/enemy_slime.tscn"),
			EnemyType.BAT: load("res://scenes/enemy_bat.tscn"),
		}
		_enemy_scenes_loaded = true
	return _enemy_scenes

static func get_enemy_type_for_wave(wave: int, random_val: float) -> EnemyType:
	if wave <= 3:
		return EnemyType.SKELETON
	elif wave <= 6:
		if random_val < 0.6:
			return EnemyType.SKELETON
		else:
			return EnemyType.SLIME
	else:
		if random_val < 0.4:
			return EnemyType.SKELETON
		elif random_val < 0.7:
			return EnemyType.SLIME
		else:
			return EnemyType.BAT

static func get_wave_enemy_count(wave: int) -> int:
	return int(wave * 5 + pow(wave, 1.3))

static func create_enemy(type: EnemyType, path) -> Enemy:
	var scenes = _get_enemy_scenes()
	var scene = scenes[type]
	var enemy = scene.instantiate()
	var config = ENEMY_CONFIGS[type]
	enemy.max_health = config.max_health
	enemy.SPEED = config.speed
	enemy.reward = config.reward
	enemy.path = path
	return enemy
