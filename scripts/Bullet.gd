extends Area2D

@export var speed: float = 400.0
@export var damage: float = 20.0

var target: Enemy = null
var _lifetime: float = 3.0

@onready var sprite = $Sprite2D

func _process(delta):
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()
		return
	
	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
		
		# 到达目标
		if global_position.distance_to(target.global_position) < 10:
			target.take_damage(damage)
			queue_free()
	else:
		queue_free()
