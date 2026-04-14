extends Node2D

# 核心游戏控制器
signal wave_started(wave: int)
signal wave_cleared
signal game_over

const TOWER_SCENE = preload("res://scenes/tower.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

@export var starting_gold: int = 100
@export var starting_lives: int = 20
@export var wave_interval: float = 10.0  # 波次间隔(秒)

var gold: int
var lives: int
var current_wave: int = 0
var is_wave_active: bool = false
var enemies_remaining: int = 0
var total_enemies_in_wave: int = 0

# 路径点 (编辑器里会可视化设置)
@export var path_points: Array[Vector2] = []

# 存档引用
var towers: Array = []
var enemies: Array = []

# UI 引用
@onready var gold_label = $UI/GoldLabel
@onready var lives_label = $UI/LivesLabel
@onready var wave_label = $UI/WaveLabel
@onready var build_panel = $UI/BuildPanel
@onready var path_node = $Path

func _ready():
	gold = starting_gold
	lives = starting_lives
	current_wave = 0
	_update_ui()
	_setup_build_panel()
	
	# 连接信号
	build_panel.tower_selected.connect(_on_tower_selected)

func _process(_delta):
	# 检查波次是否结束
	if is_wave_active and enemies_remaining <= 0 and get_tree().get_nodes_in_group("enemies").size() == 0:
		_wave_cleared()

func _update_ui():
	gold_label.text = "💰 金币: %d" % gold
	lives_label.text = "❤️ 生命: %d" % lives
	wave_label.text = "第 %d 波" % current_wave if current_wave > 0 else "准备开始"

func _setup_build_panel():
	# 注册3种塔
	build_panel.add_tower_type("箭塔", 50, preload("res://scenes/tower_arrow.tscn"))
	build_panel.add_tower_type("法师塔", 80, preload("res://scenes/tower_mage.tscn"))
	build_panel.add_tower_type("炮塔", 120, preload("res://scenes/tower_cannon.tscn"))

func _on_tower_selected(tower_scene: PackedScene, cost: int):
	if gold < cost:
		return
	gold -= cost
	_update_ui()
	# 通知 Game 即将放置塔，等待玩家点击地图
	build_panel.start_placement(tower_scene, cost)

# 玩家点击地图放置塔
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if build_panel.is_placing:
			_place_tower_at(build_panel.placing_tower_scene, get_global_mouse_position(), build_panel.placing_cost)
			build_panel.cancel_placement()

func _place_tower_at(tower_scene: PackedScene, pos: Vector2, cost: int):
	var tower = tower_scene.instantiate()
	tower.position = pos
	tower.target_reached.connect(_on_enemy_reached_tower)
	add_child(tower)
	towers.append(tower)
	gold -= cost
	_update_ui()

func start_next_wave():
	if is_wave_active:
		return
	current_wave += 1
	is_wave_active = true
	enemies_remaining = _get_wave_enemy_count()
	total_enemies_in_wave = enemies_remaining
	_update_ui()
	wave_started.emit(current_wave)
	_spawn_wave()

func _get_wave_enemy_count() -> int:
	# 波次公式: 基础5只 + 波次*3 + 波次^1.2
	return int(5 + current_wave * 3 + pow(current_wave, 1.2))

func _spawn_wave():
	var enemy_count = total_enemies_in_wave
	var spawn_delay = 1.5  # 每1.5秒出一个
	for i in range(enemy_count):
		await get_tree().create_timer(spawn_delay).timeout
		_spawn_enemy()

func _spawn_enemy():
	var enemy = ENEMY_SCENE.instantiate()
	enemy.path = path_points
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
		game_over()

func _on_enemy_died(enemy, reward: int):
	gold += reward
	enemies_remaining -= 1
	_update_ui()

func _on_enemy_reached_tower(enemy):
	# 敌人被塔攻击
	pass

func _wave_cleared():
	is_wave_active = false
	wave_cleared.emit()
	# 给奖励
	var bonus = current_wave * 10
	gold += bonus
	_update_ui()
