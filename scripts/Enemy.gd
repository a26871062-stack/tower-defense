extends Area2D
class_name Enemy

signal reached_end
signal died(enemy: Enemy, reward: int)

@export var SPEED: float = 60.0  # 像素/秒

@export var max_health: float = 100.0
@export var reward: int = 10
@export var death_effect_scene: PackedScene = preload("res://scenes/death_effect.tscn")

var health: float
var path = []
var path_index: int = 0
var is_moving: bool = false
var _health_fill_style: StyleBoxFlat
var _slow_timer: float = 0.0
var _slow_factor: float = 1.0

@onready var health_bar = $HealthBar
@onready var sprite = $Sprite2D
@onready var damage_label = $DamageLabel

func _ready():
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	add_to_group("enemies")
	_setup_health_bar_style()

func _process(delta):
	if is_moving and path.size() > 0:
		_move_along_path(delta)
	if _slow_timer > 0:
		_slow_timer -= delta
		if _slow_timer <= 0:
			_slow_factor = 1.0
			_restore_slow_color()

func start_moving():
	is_moving = true

func _move_along_path(delta):
	if path_index >= path.size():
		reached_end.emit(self)
		queue_free()
		return

	var target = path[path_index]
	var direction = (target - global_position).normalized()
	global_position += direction * SPEED * _slow_factor * delta

	# 检查是否到达当前路径点
	if global_position.distance_to(target) < 5:
		path_index += 1

func apply_slow(factor: float, duration: float):
	# factor 是速度倍率，0.5 表示速度降为50%
	_slow_factor = factor
	_slow_timer = max(_slow_timer, duration)
	# 视觉：蓝色/紫色调
	sprite.modulate = Color(0.4, 0.6, 1.0, 1.0)

func _restore_slow_color():
	sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func take_damage(amount: float):
	health -= amount
	health_bar.value = health
	_update_health_bar_color()

	# 显示浮动伤害数字
	_show_floating_damage(amount)

	# 受伤变色
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if health <= 0:
		die()

func _show_floating_damage(amount: float):
	if damage_label:
		damage_label.text = "-%d" % int(amount)
		damage_label.visible = true
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(damage_label, "position:y", damage_label.position.y - 30, 0.5)
		tween.tween_property(damage_label, "modulate:a", 0.0, 0.5)
		await tween.finished
		damage_label.visible = false
		damage_label.modulate.a = 1.0
		damage_label.position.y += 30

func die():
	SoundManager.play_sfx("enemy_death")
	_show_death_effect()
	died.emit(self, reward)
	queue_free()

func _show_death_effect():
	if death_effect_scene:
		var effect = death_effect_scene.instantiate()
		effect.global_position = global_position
		get_parent().add_child(effect)

func _setup_health_bar_style():
	var fill = health_bar.get_theme_stylebox("fill")
	if fill:
		_health_fill_style = fill.duplicate()
		health_bar.add_theme_stylebox_override("fill", _health_fill_style)

func _update_health_bar_color():
	if not _health_fill_style:
		return
	var pct = health / max_health
	if pct > 0.6:
		_health_fill_style.bg_color = Color(0.3, 0.75, 0.25)
	elif pct > 0.3:
		_health_fill_style.bg_color = Color(0.9, 0.7, 0.1)
	else:
		_health_fill_style.bg_color = Color(0.9, 0.15, 0.1)
