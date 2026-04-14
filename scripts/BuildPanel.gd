extends Control

signal tower_selected(tower_scene: PackedScene, cost: int)

const TOWER_BUTTON_SCENES = {
	"arrow": preload("res://scenes/tower_button_arrow.tscn"),
	"mage": preload("res://scenes/tower_button_mage.tscn"),
	"cannon": preload("res://scenes/tower_button_cannon.tscn"),
}

var is_placing: bool = false
var placing_tower_scene: PackedScene = null
var placing_cost: int = 0

var _tower_types: Array = []

@onready var panel = $Panel
@onready var tower_container = $Panel/VBox

func _ready():
	pass

func add_tower_type(tower_name: String, cost: int, scene: PackedScene):
	var key = "arrow"
	if "法师" in tower_name:
		key = "mage"
	elif "炮" in tower_name:
		key = "cannon"
	_tower_types.append({"name": tower_name, "cost": cost, "scene": scene, "key": key})
	_add_tower_button(tower_name, cost, key)

func _add_tower_button(tower_name: String, cost: int, key: String):
	var btn = TOWER_BUTTON_SCENES[key].instantiate()
	btn.setup(tower_name, cost)
	btn.pressed.connect(_on_tower_button_pressed.bind(len(_tower_types) - 1))
	tower_container.add_child(btn)

func _on_tower_button_pressed(index: int):
	var t = _tower_types[index]
	if t.cost > get_parent().get_parent().gold:
		return
	is_placing = true
	placing_tower_scene = t.scene
	placing_cost = t.cost
	tower_selected.emit(t.scene, t.cost)

func start_placement(tower_scene: PackedScene, cost: int):
	is_placing = true
	placing_tower_scene = tower_scene
	placing_cost = cost

func cancel_placement():
	is_placing = false
	placing_tower_scene = null
	placing_cost = 0
