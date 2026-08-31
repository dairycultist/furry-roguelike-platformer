extends Tower;

@export var projectile_prefab : PackedScene;
@export var time_of_flight : float = 1.0;
@export var explosion_radius : float = 2.0;

var barrel_alternator : bool;

func _process(delta: float) -> void:
	super._process(delta);
	
	# revert animation
	$Head/Barrel1.scale = lerp($Head/Barrel1.scale, Vector3.ONE, 5.0 * delta);
	$Head/Barrel1/MuzzleFlash.scale = lerp($Head/Barrel1/MuzzleFlash.scale, Vector3.ZERO, 12.0 * delta);
	$Head/Barrel2.scale = lerp($Head/Barrel2.scale, Vector3.ONE, 5.0 * delta);
	$Head/Barrel2/MuzzleFlash.scale = lerp($Head/Barrel2/MuzzleFlash.scale, Vector3.ZERO, 12.0 * delta);

func pick_target_to_face(in_range : Array[Node3D]) -> Node3D:
	return in_range[0];

func pick_targets_to_attack(in_range : Array[Node3D]) -> Array[Node3D]:
	
	# fire animation
	if barrel_alternator:
		$Head/Barrel1.scale = Vector3(1.2, 1.2, 0.7);
		$Head/Barrel1/MuzzleFlash.scale = Vector3(1.5, 1.5, 2.5);
	else:
		$Head/Barrel2.scale = Vector3(1.2, 1.2, 0.7);
		$Head/Barrel2/MuzzleFlash.scale = Vector3(1.5, 1.5, 2.5);
	
	# throw a projectile
	var proj := projectile_prefab.instantiate();
	
	add_child(proj);
	proj.enemy_path = enemy_path;
	proj.explosion_radius = explosion_radius;
	proj.explosion_damage = damage;
	proj.global_position = $Head/Barrel1/MuzzleFlash.global_position if barrel_alternator else $Head/Barrel2/MuzzleFlash.global_position;
	proj.initialize_velocity(time_of_flight, in_range[0].global_position);
	
	barrel_alternator = not barrel_alternator;
	
	return [];
