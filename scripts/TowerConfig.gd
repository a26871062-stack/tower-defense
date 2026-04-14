class_name TowerConfig

# 统一管理所有塔的配置数据

const CONFIGS: Dictionary = {
	"箭塔": {
		"base_damage": 20.0,
		"attack_range": 150.0,
		"fire_rate": 1.0,
		"base_cost": 50,
		"bullet_type": 0,  # Bullet.BulletType.ARROW
		"bullet_speed": 500.0,
		"slow_factor": 0.0,
		"slow_duration": 0.0,
		"splash_radius": 0.0,
	},
	"法师塔": {
		"base_damage": 35.0,
		"attack_range": 130.0,
		"fire_rate": 0.8,
		"base_cost": 80,
		"bullet_type": 1,  # Bullet.BulletType.MAGIC
		"bullet_speed": 300.0,
		"slow_factor": 0.5,
		"slow_duration": 1.0,
		"splash_radius": 0.0,
	},
	"炮塔": {
		"base_damage": 60.0,
		"attack_range": 120.0,
		"fire_rate": 0.5,
		"base_cost": 120,
		"bullet_type": 2,  # Bullet.BulletType.CANNON
		"bullet_speed": 250.0,
		"slow_factor": 0.0,
		"slow_duration": 0.0,
		"splash_radius": 50.0,
	},
}

static func get_config(tower_name: String) -> Dictionary:
	return CONFIGS.get(tower_name, CONFIGS["箭塔"])

static func get_all_tower_names() -> Array:
	return CONFIGS.keys()

static func get_base_cost(tower_name: String) -> int:
	return CONFIGS.get(tower_name, CONFIGS["箭塔"])["base_cost"]
