extends Node3D

var _velocity : Vector3;

func initialize_velocity(time_of_flight: float, dest: Vector3):
	
	_velocity.x = (dest.x - global_position.x) / time_of_flight;
	_velocity.z = (dest.z - global_position.z) / time_of_flight;
	
	_velocity.y = (dest.y - global_position.y) / time_of_flight + (time_of_flight * ProjectSettings.get_setting("physics/3d/default_gravity") / 2.0);

func _process(delta: float) -> void:
	
	global_position += _velocity * delta;
	_velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta;
	
	if (global_position.y < 0.0):
		queue_free();
