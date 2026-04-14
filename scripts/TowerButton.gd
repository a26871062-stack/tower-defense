extends Button

func setup(tower_name: String, cost: int):
	text = "%s  💰%d" % [tower_name, cost]
