extends Node3D

@export var target : Node3D;

var fire_cooldown : float;

func _process(delta: float) -> void:
	
	if target:
	
		$TurretHead.look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true);
		
		fire_cooldown -= delta;
		
		$TurretHead/TurretBarrel.scale.z = lerp($TurretHead/TurretBarrel.scale.z, 1.0, 3.0 * delta);
		
		if (fire_cooldown < 0.0):
			
			fire_cooldown = 1.0;
			$TurretHead/TurretBarrel.scale.z = 0.7;
