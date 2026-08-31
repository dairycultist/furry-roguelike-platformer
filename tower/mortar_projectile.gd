extends Node3D

var _velocity : Vector3;

var enemy_path : Node3D;
var explosion_radius : float;
var explosion_damage : int;

func initialize_velocity(time_of_flight: float, dest: Vector3):
	
	_velocity.x = (dest.x - global_position.x) / time_of_flight;
	_velocity.z = (dest.z - global_position.z) / time_of_flight;
	
	_velocity.y = (dest.y - global_position.y) / time_of_flight + (time_of_flight * ProjectSettings.get_setting("physics/3d/default_gravity") / 2.0);

func _process(delta: float) -> void:
	
	$Mesh.look_at_from_position(Vector3.ZERO, _velocity, Vector3.UP, true);
	$Mesh.position = Vector3.ZERO;
	
	global_position += _velocity * delta;
	_velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta;
	
	if (global_position.y < 0.0):
		
		# get targets in range
		for enemy in enemy_path.get_children():
			
			var dist = Vector3(enemy.global_position.x, 0.0, enemy.global_position.z).distance_to(global_position);
			
			if dist <= explosion_radius:
				enemy.attack(explosion_damage, global_position);
		
		queue_free();
