extends Line2D

var _shadow_path: Line2D
var _start_marker: Polygon2D
var _end_marker: Polygon2D

func _ready():
	# Shadow sibling for depth effect
	_shadow_path = Line2D.new()
	_shadow_path.width = width + 14.0
	_shadow_path.default_color = Color(0.04, 0.03, 0.02, 0.65)
	_shadow_path.joint_mode = Line2D.LINE_JOINT_ROUND
	_shadow_path.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_shadow_path.end_cap_mode = Line2D.LINE_CAP_ROUND
	_shadow_path.z_index = -1
	get_parent().call_deferred("add_child", _shadow_path)

	# Start marker: green glow square
	_start_marker = Polygon2D.new()
	_start_marker.color = Color(0.25, 0.65, 0.25, 0.55)
	_start_marker.polygon = PackedVector2Array([
		Vector2(-12, -12), Vector2(12, -12), Vector2(12, 12), Vector2(-12, 12)
	])
	_start_marker.z_index = -1
	get_parent().call_deferred("add_child", _start_marker)

	# End marker: red glow square
	_end_marker = Polygon2D.new()
	_end_marker.color = Color(0.75, 0.18, 0.18, 0.55)
	_end_marker.polygon = PackedVector2Array([
		Vector2(-14, -14), Vector2(14, -14), Vector2(14, 14), Vector2(-14, 14)
	])
	_end_marker.z_index = -1
	get_parent().call_deferred("add_child", _end_marker)

	width = 40.0
	default_color = Color(0.38, 0.28, 0.17, 0.92)
	joint_mode = LINE_JOINT_ROUND
	begin_cap_mode = LINE_CAP_ROUND
	end_cap_mode = LINE_CAP_ROUND
	z_index = 0

func setup_path(path_points):
	clear_points()
	for point in path_points:
		add_point(point)
	_update_shadow()
	_update_markers(path_points)

func _update_shadow():
	if _shadow_path:
		_shadow_path.clear_points()
		var offset = Vector2(5, 8)
		for i in range(get_point_count()):
			_shadow_path.add_point(get_point_position(i) + offset)

func _update_markers(path_points):
	if path_points.size() >= 2:
		_start_marker.position = path_points[0]
		_end_marker.position = path_points[-1]
