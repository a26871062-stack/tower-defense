extends Node2D

signal wave_started(wave: int)
signal wave_cleared
signal game_over

const TOWER_SCENE = preload("res://scenes/tower.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

@export var starting_gold: int = 100
@export var starting_lives: int = 20
@export var wave_interval: float = 10.0

var gold: int
var lives: int
var current_wave: int = 0
var is_wave_active: bool = false
var enemies_remaining: int = 0
var total_enemies_in_wave: int = 0

@export var path_points: Array[Vector2] = []

var towers: Array = []
var enemies: Array = []
var selected_tower: Tower = null

@onready var gold_label = $UI/GoldLabel
@onready var lives_label = $UI/LivesLabel
@onready var wave_label = $UI/WaveLabel
@onready var build_panel = $UI/BuildPanel
@onready var start_wave_btn = $UI/StartWaveButton
@onready var path_node = $Path
@onready var upgrade_ui = $UI/TowerUpgradeUI
@onready var message_label = $UI/MessageLabel

func _ready():
	gold = starting_gold
	lives = starting_lives
	current_wave = 0

	if path_points.size() == 0:
		path_points = [
			Vector2(-50, 360),
			Vector2(200, 360),
			Vector2(200, 200),
			Vector2(500, 200),
			Vector2(500, 400),
			Vector2(800, 400),
			Vector2(800, 300),
			Vector2(1100, 300),
			Vector2(1350, 300),
		]

	_update_ui()
	_setup_build_panel()
	start_wave_btn.pressed.connect(start_next_wave)
	build_panel.tower_selected.connect(_on_tower_selected)
	upgrade_ui.upgrade_tower.connect(_on_upgrade_tower)
	upgrade_ui.sell_tower.connect(_on_sell_tower)

func _process(_delta):
	if is_wave_active and enemies_remaining <= 0 and get_tree().get_nodes_in_group("enemies").size() == 0:
		_wave_cleared()

func _update_ui():
	gold_label.text = "💰 金币: %d" % gold
	lives_label.text = "❤️ 生命: %d" % lives
	wave_label.text = "第 %d 波" % current_wave if current_wave > 0 else "准备开始"

func _setup_build_panel():
	build_panel.add_tower_type("箭塔", 50, preload("res://scenes/tower_arrow.tscn"))
	build_panel.add_tower_type("法师塔", 80, preload("res://scenes/tower_mage.tscn"))
	build_panel.add_tower_type("炮塔", 120, preload("res://scenes/tower_cannon.tscn"))

func _on_tower_selected(tower_scene: PackedScene, cost: int):
	if gold < cost:
		return
	_update_ui()
	build_panel.start_placement(tower_scene, cost)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if build_panel.is_placing:
			_place_tower_at(build_panel.placing_tower_scene, get_global_mouse_position(), build_panel.placing_cost)
			build_panel.cancel_placement()
		elif selected_tower:
			selected_tower.deselect()
			selected_tower = null
			upgrade_ui.hide_upgrade_ui()

func _place_tower_at(tower_scene: PackedScene, pos: Vector2, cost: int):
	var tower = tower_scene.instantiate()
	tower.position = pos
	tower.target_reached.connect(_on_enemy_reached_tower)
	tower.tower_selected.connect(_on_tower_selected_by_user)
	tower.total_invested = cost
	add_child(tower)
	towers.append(tower)
	gold -= cost
	_update_ui()

func _on_tower_selected_by_user(tower: Tower):
	if selected_tower and selected_tower != tower:
		selected_tower.deselect()
	selected_tower = tower
	tower.select()
	upgrade_ui.show_upgrade_ui(tower)

func _on_upgrade_tower(tower: Tower):
	var cost = tower.get_upgrade_cost()
	if gold < cost:
		return
	gold -= cost
	tower.upgrade(cost)
	_update_ui()

func _on_sell_tower(tower: Tower):
	var sell_value = tower.get_sell_value()
	gold += sell_value
	towers.erase(tower)
	tower.queue_free()
	selected_tower = null
	_update_ui()

func start_next_wave():
	if is_wave_active:
		return
	current_wave += 1
	is_wave_active = true
	enemies_remaining = EnemyManager.get_wave_enemy_count(current_wave)
	total_enemies_in_wave = enemies_remaining
	_update_ui()
	_show_message("第 %d 波开始!" % current_wave)
	wave_started.emit(current_wave)
	_spawn_wave()

func _get_wave_enemy_count() -> int:
	return EnemyManager.get_wave_enemy_count(current_wave)

func _spawn_wave():
	var enemy_count = total_enemies_in_wave
	var spawn_delay = 1.5
	for i in range(enemy_count):
		await get_tree().create_timer(spawn_delay).timeout
		_spawn_enemy()

func _spawn_enemy():
	var rand_val = randf()
	var enemy_type = EnemyManager.get_enemy_type_for_wave(current_wave, rand_val)
	var enemy = EnemyManager.create_enemy(enemy_type, path_points)
	enemy.reached_end.connect(_on_enemy_reached_end)
	enemy.died.connect(_on_enemy_died)
	add_child(enemy)
	enemies.append(enemy)
	enemy.start_moving()

func _on_enemy_reached_end(enemy):
	lives -= 1
	enemies_remaining -= 1
	enemy.queue_free()
	_update_ui()
	if lives <= 0:
		game_over.emit()

func _on_enemy_died(_enemy, reward: int):
	gold += reward
	enemies_remaining -= 1
	_update_ui()

func _on_enemy_reached_tower(_enemy):
	pass

func _wave_cleared():
	is_wave_active = false
	_show_message("第 %d 波完成! +%d 金币奖励" % [current_wave, current_wave * 5])
	wave_cleared.emit()
	var bonus = current_wave * 5
	gold += bonus
	_update_ui()

func _show_message(msg: String):
	message_label.text = msg
	message_label.show()
	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 0.0, 2.0)
	await tween.finished
	message_label.hide()
	message_label.modulate.a = 1.0
