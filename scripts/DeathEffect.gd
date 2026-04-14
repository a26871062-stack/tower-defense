extends Node2D

var _particles: Array = []
var _duration: float = 0.4
var _elapsed: float = 0.0

func _ready():
	for i in range(6):
		var circle = ColorRect.new()
		circle.size = Vector2(10, 10)
		circle.color = Color(1, 0.3, 0.1, 0.8)
		circle.position = Vector2(-5, -5)
		add_child(circle)
		_particles.append({
			"node": circle,
			"angle": randf() * TAU,
			"speed": 50 + randf() * 50,
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
