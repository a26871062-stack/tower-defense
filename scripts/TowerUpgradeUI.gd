extends Control

signal upgrade_tower(tower: Tower)
signal sell_tower(tower: Tower)

var current_tower: Tower = null

@onready var panel = $Panel
@onready var tower_name_label = $Panel/VBox/TowerNameLabel
@onready var level_label = $Panel/VBox/UpgradeTowerLevelLabel
@onready var upgrade_btn = $Panel/VBox/UpgradeButton
@onready var upgrade_cost_label = $Panel/VBox/UpgradeButton/CostLabel
@onready var sell_btn = $Panel/VBox/SellButton
@onready var sell_value_label = $Panel/VBox/SellButton/ValueLabel

func _ready():
	print("[DEBUG] TowerUpgradeUI ready, btn=", upgrade_btn, " sell_btn=", sell_btn)
	panel.hide()
	upgrade_btn.pressed.connect(_on_upgrade_button_pressed)
	sell_btn.pressed.connect(_on_sell_button_pressed)

func show_upgrade_ui(tower: Tower):
	current_tower = tower
	panel.show()
	mouse_filter = Control.MOUSE_FILTER_PASS
	# Hide build panel while upgrade UI is open
	if get_parent():
		var build_panel = get_parent().get_node_or_null("BuildPanel")
		if build_panel:
			build_panel.hide()
	_update_ui()

func hide_upgrade_ui():
	panel.hide()
	current_tower = null
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Show build panel again
	if get_parent():
		var build_panel = get_parent().get_node_or_null("BuildPanel")
		if build_panel:
			build_panel.show()

func _update_ui():
	if not current_tower:
		return

	tower_name_label.text = current_tower.tower_name
	level_label.text = "等级: %d / 3" % current_tower.level

	var upgrade_cost = current_tower.get_upgrade_cost()
	var sell_value = current_tower.get_sell_value()

	if current_tower.level >= 3:
		upgrade_btn.disabled = true
		upgrade_cost_label.text = "满级"
	else:
		upgrade_btn.disabled = false
		upgrade_cost_label.text = "%d 金币" % upgrade_cost

	sell_value_label.text = "%d 金币" % sell_value

func _on_upgrade_button_pressed():
	print("[DEBUG] Upgrade button pressed! current_tower=", current_tower)
	if current_tower and current_tower.can_upgrade():
		upgrade_tower.emit(current_tower)
		_update_ui()

func _on_sell_button_pressed():
	print("[DEBUG] Sell button pressed! current_tower=", current_tower)
	if current_tower:
		sell_tower.emit(current_tower)
		hide_upgrade_ui()
