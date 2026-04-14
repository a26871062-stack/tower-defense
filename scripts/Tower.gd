extends Area2D
class_name Tower

signal tower_selected(tower: Tower)
signal tower_deselected

@export var tower_name: String = "箭塔"
@export var base_damage: float = 20.0
@export var attack_range: float = 150.0
@export var fire_rate: float = 1.0
@export var base_cost: int = 50

const MAX_LEVEL: int = 3
const UPGRADE_DAMAGE_MULTIPLIER: float = 1.5
const UPGRADE_COST_MULTIPLIER: float = 0.6
const SELL_RETURN_RATE: float = 0.5

var level: int = 1
var total_invested: int = 0
var is_selected: bool = false

var damage: float:
	get: return base_damage * pow(UPGRADE_DAMAGE_MULTIPLIER, level - 1)

var _fire_cooldown: float = 0.0
var _current_target: Enemy = null

@onready var range_indicator = $RangeIndicator
@onready var sprite = $Sprite2D
@onready var attack_timer = $AttackTimer
@onready var level_label = $LevelLabel

func _ready():
	range_indicator.hide()
	level_label.hide()
	attack_timer.wait_time = 1.0 / fire_rate
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	_set_level_indicator()

func _process(delta):
	_fire_cooldown -= delta
	_current_target = _find_closest_enemy()
	if _current_target:
		look_at(_current_target.global_position)
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
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	_create_projectile(target)

func _create_projectile(target: Enemy):
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

func _on_mouse_entered():
	if not is_selected:
		range_indicator.show()

func _on_mouse_exited():
	if not is_selected:
		range_indicator.hide()

func select():
	if is_selected:
		return
	is_selected = true
	range_indicator.show()
	level_label.show()
	tower_selected.emit(self)

func deselect():
	if not is_selected:
		return
	is_selected = false
	range_indicator.hide()
	level_label.hide()
	tower_deselected.emit()

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_selected:
			deselect()
		else:
			select()

func can_upgrade() -> bool:
	return level < MAX_LEVEL

func get_upgrade_cost() -> int:
	if not can_upgrade():
		return 0
	return int(base_cost * UPGRADE_COST_MULTIPLIER * level)

func upgrade(upgrade_cost: int) -> bool:
	if not can_upgrade():
		return false
	level += 1
	total_invested += upgrade_cost
	_set_level_indicator()
	return true

func get_sell_value() -> int:
	return int(total_invested * SELL_RETURN_RATE)

func _set_level_indicator():
	if level_label:
		var stars = ""
		for i in range(level):
			stars += "★"
		for i in range(MAX_LEVEL - level):
			stars += "☆"
		level_label.text = stars
