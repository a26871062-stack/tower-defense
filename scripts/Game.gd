extends Node2D

signal wave_started(wave: int)
signal wave_cleared
signal level_cleared(level: int)
signal game_over

const TOWER_SCENE = preload("res://scenes/tower.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

@export var starting_gold: int = 100
@export var starting_lives: int = 20
@export var wave_interval: float = 10.0
@export var waves_per_level: int = 3  # 每个关卡的波次数

var gold: int
var lives: int
var current_wave: int = 0
var is_wave_active: bool = false
var enemies_remaining: int = 0
var total_enemies_in_wave: int = 0

var current_level_index: int = 0
var is_level_active: bool = false

var path_points = []

var towers: Array = []
var enemies: Array = []
var selected_tower: Tower = null

var _is_placing_preview: bool = false
var _placement_range: float = 150.0
var _placement_pos: Vector2 = Vector2.ZERO

var game_speed: float = 1.0

@onready var gold_label = $UI/GoldLabel
@onready var lives_label = $UI/LivesLabel
@onready var wave_label = $UI/WaveLabel
@onready var level_label = $UI/LevelLabel
@onready var build_panel = $UI/BuildPanel
@onready var start_wave_btn = $UI/TopBar/StartWaveButton
@onready var next_level_btn = $UI/TopBar/NextLevelButton
@onready var speed_down_btn = $UI/TopBarRight/SpeedDownButton
@onready var speed_label = $UI/TopBarRight/SpeedLabel
@onready var speed_up_btn = $UI/TopBarRight/SpeedUpButton
@onready var pause_btn = $UI/TopBarRight/PauseButton
@onready var path_node = $Path
@onready var path_visual = $Path/PathVisual
@onready var upgrade_ui = $UI/TowerUpgradeUI
@onready var message_label = $UI/MessageLabel

func _ready():
	_load_level(0)
	_setup_build_panel()
	start_wave_btn.pressed.connect(start_next_wave)
	next_level_btn.pressed.connect(_on_next_level_pressed)
	speed_down_btn.pressed.connect(_on_speed_down)
	speed_up_btn.pressed.connect(_on_speed_up)
	pause_btn.pressed.connect(_toggle_pause)
	build_panel.tower_selected.connect(_on_tower_selected)
	upgrade_ui.upgrade_tower.connect(_on_upgrade_tower)
	upgrade_ui.sell_tower.connect(_on_sell_tower)
	build_panel.insufficient_gold.connect(_on_insufficient_gold)
	build_panel.placement_started.connect(_on_placement_started)
	build_panel.placement_cancelled.connect(_on_placement_cancelled)
	game_over.connect(_on_game_over)
	level_cleared.connect(_on_level_cleared)
	_update_speed_label()

func _load_level(level_index: int):
	current_level_index = level_index
	var level_data = LevelManager.get_level(level_index)
	path_points = level_data["path"]
	
	# Reset wave state
	current_wave = 0
	is_wave_active = false
	is_level_active = true
	
	# Init gold/lives from starting values
	if level_index == 0:
		gold = starting_gold
		lives = starting_lives
	else:
		gold += level_data.get("bonus_gold", 0)
		lives += level_data.get("bonus_lives", 0)
	
	# Clear existing towers
	for tower in towers:
		tower.queue_free()
	towers.clear()

	# Draw path visually
	if path_visual:
		path_visual.setup_path(path_points)
	
	_update_ui()
	next_level_btn.hide()
	start_wave_btn.show()

func _update_ui():
	var level_data = LevelManager.get_level(current_level_index)
	level_label.text = level_data["name"]
	wave_label.text = "第 %d/%d 波" % [current_wave, waves_per_level] if current_wave > 0 else "准备开始"
	gold_label.text = "💰 金币: %d" % gold
	lives_label.text = "❤️ 生命: %d" % lives

func _setup_build_panel():
	build_panel.add_tower_type("箭塔", 50, 150.0, preload("res://scenes/tower_arrow.tscn"))
	build_panel.add_tower_type("法师塔", 80, 130.0, preload("res://scenes/tower_mage.tscn"))
	build_panel.add_tower_type("炮塔", 120, 120.0, preload("res://scenes/tower_cannon.tscn"))

func _on_tower_selected(tower_scene: PackedScene, cost: int):
	if build_panel.is_placing:
		return  # Already placing
	_update_ui()
	build_panel.start_placement(tower_scene, cost)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if build_panel.is_placing:
			_place_tower_at(build_panel.placing_tower_scene, get_global_mouse_position(), build_panel.placing_cost)
			build_panel.cancel_placement()
			build_panel.show()
		elif selected_tower:
			# Check if click is inside any UI node (upgrade UI or build panel)
			var click_pos = event.global_position
			var ui = $UI
			var clicked_on_ui = false
			for child in ui.get_children():
				if child is Control and child.visible and child.get_global_rect().has_point(click_pos):
					clicked_on_ui = true
					break
			if not clicked_on_ui:
				selected_tower.deselect()
				selected_tower = null
				upgrade_ui.hide_upgrade_ui()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if build_panel.is_placing:
				build_panel.cancel_placement()
				build_panel.show()
			elif selected_tower:
				selected_tower.deselect()
			selected_tower = null
			upgrade_ui.hide_upgrade_ui()
		elif event.keycode == KEY_P:
			_toggle_pause()
		elif event.keycode == KEY_EQUAL or event.keycode == KEY_KP_ADD:
			_change_speed(0.5)
		elif event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT:
			_change_speed(-0.5)

func _place_tower_at(tower_scene: PackedScene, pos: Vector2, cost: int):
	if gold < cost:
		_show_message("金币不足！需要 %d 金币" % cost)
		build_panel.cancel_placement()
		build_panel.show()
		return
	for existing_tower in towers:
		if existing_tower.position.distance_to(pos) < 40:
			_show_message("这里已经有塔了！")
			build_panel.cancel_placement()
			build_panel.show()
			return
	var tower = tower_scene.instantiate()
	tower.position = pos
	tower.target_reached.connect(_on_enemy_reached_tower)
	tower.tower_selected.connect(_on_tower_selected_by_user)
	tower.total_invested = cost
	add_child(tower)
	towers.append(tower)
	gold -= cost
	build_panel.show()
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
		_show_message("金币不足！需要 %d 金币" % cost)
		return
	gold -= cost
	tower.upgrade(cost)
	SoundManager.play_sfx("upgrade")
	_update_ui()

func _on_sell_tower(tower: Tower):
	var sell_value = tower.get_sell_value()
	gold += sell_value
	towers.erase(tower)
	tower.queue_free()
	selected_tower = null
	SoundManager.play_sfx("sell")
	_update_ui()

func start_next_wave():
	if is_wave_active:
		return
	if current_wave >= waves_per_level:
		return
	current_wave += 1
	is_wave_active = true
	var level_data = LevelManager.get_level(current_level_index)
	enemies_remaining = int(EnemyManager.get_wave_enemy_count(current_wave) * level_data["enemy_mult"])
	total_enemies_in_wave = enemies_remaining
	_update_ui()
	_show_message("第 %d 波开始!" % current_wave)
	wave_started.emit(current_wave)
	_spawn_wave()

func _spawn_wave():
	var enemy_count = total_enemies_in_wave
	var spawn_delay = 1.2
	for i in range(enemy_count):
		await get_tree().create_timer(spawn_delay).timeout
		_spawn_enemy()

func _spawn_enemy():
	var rand_val = randf()
	var enemy_type = EnemyManager.get_enemy_type_for_wave(current_wave, rand_val)
	var enemy = EnemyManager.create_enemy(enemy_type, path_points)
	enemy.reached_end.connect(_on_enemy_reached_end)
	enemy.died.connect(_on_enemy_died)
	enemy.position = path_points[0]  # Start at path beginning
	add_child(enemy)
	enemies.append(enemy)
	enemy.start_moving()

func _on_enemy_reached_end(enemy):
	if lives <= 0:
		return
	lives = max(0, lives - 1)
	enemies_remaining -= 1
	enemy.queue_free()
	_update_ui()
	if lives <= 0:
		game_over.emit()

func _on_enemy_died(_enemy, reward: int):
	gold += reward
	enemies_remaining -= 1
	SoundManager.play_sfx("coin")
	_update_ui()

func _on_enemy_reached_tower(_enemy):
	pass

func _wave_cleared():
	is_wave_active = false
	var wave_bonus = current_wave * 5
	gold += wave_bonus
	_show_message("第 %d 波完成! +%d 金币" % [current_wave, wave_bonus])
	wave_cleared.emit()
	_update_ui()
	
	# Check if level complete
	if current_wave >= waves_per_level:
		_show_level_complete()

func _show_level_complete():
	is_level_active = false
	var level_data = LevelManager.get_level(current_level_index)
	var bonus = level_data.get("bonus_gold", 30)
	gold += bonus
	level_cleared.emit(current_level_index)
	_show_message("🎉 %s 完成! +%d 金币" % [level_data["name"], bonus])
	start_wave_btn.hide()
	
	# Check if there's a next level
	if current_level_index + 1 < LevelManager.get_total_levels():
		next_level_btn.show()
		next_level_btn.text = "进入 %s" % LevelManager.get_level(current_level_index + 1)["name"]
	else:
		_show_message("🏆 所有关卡通关！你赢了！")
		get_tree().paused = true

func _on_level_cleared(level: int):
	pass

func _on_next_level_pressed():
	_load_level(current_level_index + 1)

func _process(_delta):
	if is_wave_active and enemies_remaining <= 0 and get_tree().get_nodes_in_group("enemies").size() == 0:
		_wave_cleared()
	if _is_placing_preview:
		_placement_pos = get_global_mouse_position()
		queue_redraw()

func _toggle_pause():
	var is_paused = Engine.time_scale == 0.0
	if is_paused:
		Engine.time_scale = game_speed if game_speed > 0 else 1.0
		_show_message("继续")
		pause_btn.text = "⏸ 暂停"
		speed_label.add_theme_color_override("font_color", Color(0.96, 0.71, 0.17))
	else:
		Engine.time_scale = 0.0
		_show_message("暂停")
		pause_btn.text = "▶ 继续"
		speed_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

func _change_speed(delta: float):
	game_speed = clamp(game_speed + delta, 0.5, 3.0)
	Engine.time_scale = game_speed
	_update_speed_label()

func _on_speed_down():
	_change_speed(-0.5)

func _on_speed_up():
	_change_speed(0.5)

func _update_speed_label():
	speed_label.text = "%.1fx" % game_speed

func _draw():
	if _is_placing_preview:
		var preview_color = Color(0.2, 0.6, 1.0, 0.15)
		var border_color = Color(0.2, 0.6, 1.0, 0.6)
		draw_circle(_placement_pos, _placement_range, preview_color)
		draw_arc(_placement_pos, _placement_range, 0, TAU, 64, border_color, 2.0)

func _show_message(msg: String):
	message_label.text = msg
	message_label.show()
	message_label.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 0.0, 2.0)
	await tween.finished
	message_label.hide()

func _on_insufficient_gold(msg: String):
	_show_message(msg)

func _on_placement_started(tower_name: String, attack_range: float):
	_is_placing_preview = true
	_placement_range = attack_range
	build_panel.hide()  # Hide build panel while placing
	queue_redraw()

func _on_placement_cancelled():
	_is_placing_preview = false
	queue_redraw()

func _on_game_over():
	is_wave_active = false
	is_level_active = false
	get_tree().paused = true
	_show_message("💀 游戏结束！")
