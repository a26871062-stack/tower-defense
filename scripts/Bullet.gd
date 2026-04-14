extends Area2D

enum BulletType { ARROW, MAGIC, CANNON }

@export var speed: float = 400.0
@export var damage: float = 20.0
@export var bullet_type: BulletType = BulletType.ARROW
@export var splash_radius: float = 0.0
@export var slow_factor: float = 0.0
@export var slow_duration: float = 0.0

var target: Enemy = null
var _lifetime: float = 3.0

@onready var sprite = $Sprite2D

func _process(delta):
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()
		return

	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta

		# 到达目标
		if global_position.distance_to(target.global_position) < 10:
			_on_hit()
			queue_free()
	else:
		queue_free()

func _on_hit():
	if not target or not is_instance_valid(target):
		return
	target.take_damage(damage)

	# 炮塔范围伤害
	if splash_radius > 0:
		_do_splash_damage()

	# 法师塔减速
	if slow_factor > 0 and target and is_instance_valid(target):
		target.apply_slow(slow_factor, slow_duration)

func _do_splash_damage():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy == target:
			continue
		if enemy.global_position.distance_to(global_position) <= splash_radius:
			enemy.take_damage(damage * 0.5)
