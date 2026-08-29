extends Node3D

@export var max_targeting_distance : int = 3;

var enemy_path : Node3D;
var target : Node3D;

var fire_cooldown : float;

func _process(delta: float) -> void:
	
	$Radius.size = Vector3(1.0 + max_targeting_distance * 2, 2.0, 1.0 + max_targeting_distance * 2) # TEMP idk how im gonna set size fr but whatever
	target = enemy_path.get_child(0); # TEMP, replace with targeting logic
	
	# exhaust cooldown
	if (not fire_cooldown < 0.0):
		fire_cooldown -= delta;
	
	# turret animation
	$TurretHead/TurretBarrel.scale.z = lerp($TurretHead/TurretBarrel.scale.z, 1.0, 3.0 * delta);
	
	if target:
	
		# fire at target
		$TurretHead.look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true);
		
		if (fire_cooldown < 0.0):
			
			fire_cooldown = 1.0;
			$TurretHead/TurretBarrel.scale.z = 0.7;
	
	else:
		
		$TurretHead.global_rotation.y += 0.5 * delta;
