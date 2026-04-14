extends Control

signal tower_selected(tower_scene: PackedScene, cost: int)
signal insufficient_gold(msg: String)
signal placement_started(tower_name: String, attack_range: float)
signal placement_moved(pos: Vector2)
signal placement_cancelled

const TOWER_BUTTON_SCENES = {
	"arrow": preload("res://scenes/tower_button_arrow.tscn"),
	"mage": preload("res://scenes/tower_button_mage.tscn"),
	"cannon": preload("res://scenes/tower_button_cannon.tscn"),
}

var is_placing: bool = false
var placing_tower_scene: PackedScene = null
var placing_cost: int = 0
var placing_tower_name: String = ""
var placing_attack_range: float = 150.0

var _tower_types: Array = []

@onready var panel = $Panel
@onready var tower_container = $Panel/VBox

func _ready():
	pass

func add_tower_type(tower_name: String, cost: int, attack_range: float, scene: PackedScene):
	var key = "arrow"
	if "法师" in tower_name:
		key = "mage"
	elif "炮" in tower_name:
		key = "cannon"
	_tower_types.append({"name": tower_name, "cost": cost, "scene": scene, "key": key, "range": attack_range})
	_add_tower_button(tower_name, cost, key)

func _add_tower_button(tower_name: String, cost: int, key: String):
	var btn = TOWER_BUTTON_SCENES[key].instantiate()
	btn.setup(tower_name, cost)
	btn.pressed.connect(_on_tower_button_pressed.bind(len(_tower_types) - 1))
	tower_container.add_child(btn)

func _on_tower_button_pressed(index: int):
	if is_placing:
		return  # Already placing, ignore repeated clicks
	var t = _tower_types[index]
	if t.cost > get_parent().get_parent().gold:
		insufficient_gold.emit("金币不足！需要 %d 金币" % t.cost)
		return
	is_placing = true
	placing_tower_scene = t.scene
	placing_cost = t.cost
	placing_tower_name = t.name
	placing_attack_range = t.get("range", 150.0)
	tower_selected.emit(t.scene, t.cost)
	placement_started.emit(t.name, placing_attack_range)

func start_placement(tower_scene: PackedScene, cost: int):
	is_placing = true
	placing_tower_scene = tower_scene
	placing_cost = cost

func cancel_placement():
	is_placing = false
	placing_tower_scene = null
	placing_cost = 0
	placing_tower_name = ""
	placing_attack_range = 150.0
	placement_cancelled.emit()
