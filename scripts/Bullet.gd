extends Area2D

enum BulletType { ARROW, MAGIC, CANNON }

@export var speed: float = 400.0
@export var damage: float = 20.0
@export var bullet_type: BulletType = BulletType.ARROW
@export var splash_radius: float = 0.0
@export var slow_factor: float = 0.0
@export var slow_duration: float = 0.0

const EXPLOSION = preload("res://scenes/explosion.tscn")

var target: Enemy = null
var _lifetime: float = 3.0

@onready var sprite: Sprite2D = $Sprite2D


func _ready():
	# 根据子弹类型设置外观（颜色 + 缩放）
	match bullet_type:
		BulletType.ARROW:
			sprite.modulate = Color(1.0, 0.95, 0.7)
			sprite.scale = Vector2(0.5, 0.12)
		BulletType.MAGIC:
			sprite.modulate = Color(0.6, 0.5, 1.0)
			sprite.scale = Vector2(0.4, 0.4)
		BulletType.CANNON:
			sprite.modulate = Color(1.0, 0.6, 0.2)
			sprite.scale = Vector2(0.35, 0.35)


func _process(delta):
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()
		return

	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta

		# 箭塔子弹旋转朝向
		if bullet_type == BulletType.ARROW:
			sprite.rotation = direction.angle()

		# 到达目标
		if global_position.distance_to(target.global_position) < 10:
			_do_hit()
			queue_free()
	else:
		# 目标已死亡/无效：触发一次 hit 再消失
		_do_hit()
		queue_free()


func _do_hit():
	if not target or not is_instance_valid(target):
		return
	target.take_damage(damage)

	# 炮塔范围伤害 + 爆炸特效
	if splash_radius > 0:
		_do_splash_damage()
		_spawn_explosion()

	# 法师塔减速
	if slow_factor > 0:
		target.apply_slow(slow_factor, slow_duration)


func _do_splash_damage():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy == target:
			continue
		if enemy.global_position.distance_to(global_position) <= splash_radius:
			enemy.take_damage(damage * 0.5)


func _spawn_explosion():
	var exp = EXPLOSION.instantiate()
	exp.global_position = global_position
	get_parent().add_child(exp)
