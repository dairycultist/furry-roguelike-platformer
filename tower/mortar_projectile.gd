extends Node3D

var _velocity : Vector3;

func initialize_velocity(source: Vector3, dest: Vector3):
	
	_velocity.x = dest.x - source.x;
	_velocity.z = dest.z - source.z;
	
	_velocity.y = dest.y - source.y + ProjectSettings.get_setting("physics/3d/default_gravity") / 2.0;

func _process(delta: float) -> void:
	
	global_position += _velocity * delta;
	_velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta;
	
	if (global_position.y < 0.0):
		queue_free();
