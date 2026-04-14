extends Line2D

func _ready():
	width = 40.0
	default_color = Color(0.3, 0.25, 0.2, 0.8)  # 泥土色
	joint_mode = Line2D.LINE_JOINT_ROUND
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND

func setup_path(path_points):
	clear_points()
	for point in path_points:
		add_point(point)
