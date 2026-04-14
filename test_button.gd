extends Node

func _ready():
	print("[TEST] test_button.gd running")
	await get_tree().create_timer(1.0).timeout
	var upgrade_ui = get_node_or_null("/root/Main/UI/TowerUpgradeUI")
	if upgrade_ui:
		print("[TEST] Found TowerUpgradeUI")
		upgrade_ui.show_upgrade_ui(null)  # This will crash or show UI
	else:
		print("[TEST] TowerUpgradeUI not found at expected path")
	get_tree().quit()
