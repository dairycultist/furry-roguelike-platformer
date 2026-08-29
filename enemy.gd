extends PathFollow3D;

@export var _speed : float = 1.0;
@export var _health : int = 3;

func attack(dmg : int) -> void:
	_health -= dmg;
	if _health <= 0:
		queue_free();

func _process(delta: float) -> void:
	progress += _speed * delta;
