extends Node2D

var _particles: Array = []
var _duration: float = 0.4
var _elapsed: float = 0.0
var _base_color: Color = Color(1, 0.3, 0.1)

func setup(color: Color = Color(1, 0.3, 0.1)):
	_base_color = color
	for p in _particles:
		p["node"].color = _base_color

func _ready():
	for i in range(8):
		var circle = ColorRect.new()
		circle.size = Vector2(8, 8)
		circle.color = _base_color
		circle.position = Vector2(-4, -4)
		add_child(circle)
		_particles.append({
			"node": circle,
			"angle": randf() * TAU,
			"speed": 40 + randf() * 60,
		})

func _process(delta):
	_elapsed += delta
	var t = _elapsed / _duration

	for p in _particles:
		var node: ColorRect = p["node"]
		var dist: float = p["speed"] * _elapsed
		var angle: float = p["angle"]
		node.position = Vector2(cos(angle) * dist, sin(angle) * dist) - Vector2(5, 5)
		node.modulate.a = 1.0 - t
		node.scale = Vector2.ONE * (1.0 + t * 0.5)

	if _elapsed >= _duration:
		queue_free()
