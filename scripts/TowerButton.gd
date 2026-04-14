extends Button

var _tower_name: String = ""
var _cost: int = 0

func setup(tower_name: String, cost: int):
	_tower_name = tower_name
	_cost = cost
	text = "%s  💰%d" % [tower_name, cost]
