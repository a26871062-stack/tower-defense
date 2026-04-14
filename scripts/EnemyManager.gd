extends Node2D

class_name EnemyManager

enum EnemyType { SKELETON, SLIME, BAT }

const ENEMY_SCENES = {
	EnemyType.SKELETON: preload("res://scenes/enemy_skeleton.tscn"),
	EnemyType.SLIME: preload("res://scenes/enemy_slime.tscn"),
	EnemyType.BAT: preload("res://scenes/enemy_bat.tscn"),
}

const ENEMY_CONFIGS = {
	EnemyType.SKELETON: {"max_health": 100.0, "speed": 60.0, "reward": 10},
	EnemyType.SLIME: {"max_health": 60.0, "speed": 35.0, "reward": 5},
	EnemyType.BAT: {"max_health": 40.0, "speed": 100.0, "reward": 8},
}

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
	return int(5 + wave * 3 + pow(wave, 1.2))

static func create_enemy(type: EnemyType, path: Array[Vector2]) -> Enemy:
	var scene = ENEMY_SCENES[type]
	var enemy = scene.instantiate()
	var config = ENEMY_CONFIGS[type]
	enemy.max_health = config.max_health
	enemy.SPEED = config.speed
	enemy.reward = config.reward
	enemy.path = path
	return enemy
