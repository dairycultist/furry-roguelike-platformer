extends Node3D

@export var damage : int = 1;
@export var max_targeting_distance : int = 3;

var enemy_path : Node3D;
var target : Node3D;

var fire_cooldown : float;

var poked : bool;

func _process(delta: float) -> void:
	
	if poked:
		poked = false;
	else:
		$Radius.visible = false;
	
	# retargeting when no target or target out of range
	if not target or Vector3(target.global_position.x, 0.0, target.global_position.z).distance_to(global_position) > max_targeting_distance + 0.5:
		
		target = null;
		
		for enemy in enemy_path.get_children():
		
			if Vector3(enemy.global_position.x, 0.0, enemy.global_position.z).distance_to(global_position) <= max_targeting_distance + 0.5:
				target = enemy;
	
	# exhaust cooldown
	if (not fire_cooldown < 0.0):
		fire_cooldown -= delta;
	
	# animation
	$Head/Barrel.scale = lerp($Head/Barrel.scale, Vector3.ONE, 5.0 * delta);
	$Head/Barrel/MuzzleFlash.scale = lerp($Head/Barrel/MuzzleFlash.scale, Vector3.ZERO, 12.0 * delta);
	
	if target:
	
		# fire at target
		$Head.look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true);
		
		if (fire_cooldown < 0.0):
			
			fire_cooldown = 1.0;
			$Head/Barrel.scale = Vector3(1.2, 1.2, 0.7);
			$Head/Barrel/MuzzleFlash.scale = Vector3(1.5, 1.5, 2.5);
			target.attack(damage);
	
	else:
		
		$Head.global_rotation.y += 0.5 * delta;

func poke():
	
	poked = true;
	
	$Radius.size = Vector3(1.0 + max_targeting_distance * 2, 2.0, 1.0 + max_targeting_distance * 2);
	$Radius.visible = true;
