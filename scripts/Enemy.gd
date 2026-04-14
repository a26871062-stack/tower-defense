extends Area2D
class_name Enemy

signal reached_end
signal died(enemy: Enemy, reward: int)

const SPEED: float = 60.0  # 像素/秒

@export var max_health: float = 100.0
@export var reward: int = 10

var health: float
var path: Array[Vector2] = []
var path_index: int = 0
var is_moving: bool = false

@onready var health_bar = $HealthBar
@onready var sprite = $Sprite2D

func _ready():
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	add_to_group("enemies")

func _process(delta):
	if is_moving and path.size() > 0:
		_move_along_path(delta)

func start_moving():
	is_moving = true

func _move_along_path(delta):
	if path_index >= path.size():
		reached_end.emit()
		queue_free()
		return
	
	var target = path[path_index]
	var direction = (target - global_position).normalized()
	global_position += direction * SPEED * delta
	
	# 检查是否到达当前路径点
	if global_position.distance_to(target) < 5:
		path_index += 1

func take_damage(amount: float):
	health -= amount
	health_bar.value = health
	
	# 受伤变色
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	if health <= 0:
		die()

func die():
	died.emit(self, reward)
	queue_free()
