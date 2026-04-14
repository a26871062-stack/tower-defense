extends Area2D
class_name Tower

signal target_reached(enemy: Enemy)

@export var tower_name: String = "箭塔"
@export var damage: float = 20.0
@export var attack_range: float = 150.0  # 攻击范围
@export var fire_rate: float = 1.0  # 每秒攻击次数
@export var cost: int = 50

var _fire_cooldown: float = 0.0
var _current_target: Enemy = null

@onready var range_indicator = $RangeIndicator
@onready var sprite = $Sprite2D
@onready var attack_timer = $AttackTimer

func _ready():
	# 显示攻击范围（初始隐藏）
	range_indicator.hide()
	
	# 攻击计时器
	attack_timer.wait_time = 1.0 / fire_rate
	
	# 连接敌人死亡信号
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(delta):
	_fire_cooldown -= delta
	
	# 找最近敌人
	_current_target = _find_closest_enemy()
	
	# 面向敌人
	if _current_target:
		look_at(_current_target.global_position)
	
	# 自动攻击
	if _current_target and _fire_cooldown <= 0:
		attack(_current_target)
		_fire_cooldown = 1.0 / fire_rate

func _find_closest_enemy() -> Enemy:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Enemy = null
	var closest_dist = INF
	
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist <= attack_range and dist < closest_dist:
			closest = enemy
			closest_dist = dist
	
	return closest

func attack(target: Enemy):
	# 播放攻击动画
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	# 创建子弹/特效
	_create_projectile(target)

func _create_projectile(target: Enemy):
	# 发射Bullet
	var bullet = preload("res://scenes/bullet.tscn").instantiate()
	bullet.global_position = global_position
	bullet.target = target
	bullet.damage = damage
	bullet.add_to_group("projectiles")
	get_parent().add_child(bullet)

func _on_area_entered(area):
	if area is Enemy:
		target_reached.emit(area)

func _on_area_exited(area):
	if area is Enemy and area == _current_target:
		_current_target = null

# 鼠标悬停显示范围
func _on_mouse_entered():
	range_indicator.show()

func _on_mouse_exited():
	range_indicator.hide()
