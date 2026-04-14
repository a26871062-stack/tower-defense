extends Button

func setup(name: String, cost: int):
	$NameLabel.text = name
	$CostLabel.text = "💰 %d" % cost
