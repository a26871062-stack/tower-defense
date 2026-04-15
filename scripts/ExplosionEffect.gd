extends Node2D

var _duration: float = 0.35
var _elapsed: float = 0.0

@onready var ring: ColorRect = $Ring
@onready var center: ColorRect = $Center

func _ready():
	# 中心闪光粒子
	for i in range(8):
		var p = ColorRect.new()
		p.size = Vector2(6, 6)
		p.color = Color(1.0, 0.6, 0.1, 1.0)
		p.position = Vector2(-3, -3)
		add_child(p)
		var angle = randf() * TAU
		var dist = 10 + randf() * 10
		p.position = Vector2(cos(angle) * dist, sin(angle) * dist) - Vector2(3, 3)
		p.modulate.a = 0.9

func _process(delta):
	_elapsed += delta
	var t = _elapsed / _duration

	# 中心白色闪光淡出
	center.modulate.a = max(0.0, 1.0 - t * 3)
	center.scale = Vector2.ONE * (1.0 + t * 1.5)

	# 冲击波圆环扩大淡出
	ring.modulate.a = max(0.0, 1.0 - t * 2)
	ring.scale = Vector2.ONE * (0.5 + t * 2.5)
	ring.rotation += delta * 5

	if _elapsed >= _duration:
		queue_free()
