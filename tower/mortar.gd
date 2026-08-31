extends Tower;

@export var projectile_prefab : PackedScene;
@export var time_of_flight : float = 1.0;
@export var explosion_radius : float = 2.0;

func _process(delta: float) -> void:
	super._process(delta);
	
	# revert animation
	$Head/Barrel.scale = lerp($Head/Barrel.scale, Vector3.ONE, 5.0 * delta);
	$Head/Barrel/MuzzleFlash.scale = lerp($Head/Barrel/MuzzleFlash.scale, Vector3.ZERO, 12.0 * delta);

func pick_target_to_face(in_range : Array[Node3D]) -> Node3D:
	return in_range[0];

func pick_targets_to_attack(in_range : Array[Node3D]) -> Array[Node3D]:
	
	# fire animation
	$Head/Barrel.scale = Vector3(1.2, 1.2, 0.7);
	$Head/Barrel/MuzzleFlash.scale = Vector3(1.5, 1.5, 2.5);
	
	# throw a projectile
	var proj := projectile_prefab.instantiate();
	
	add_child(proj);
	proj.enemy_path = enemy_path;
	proj.explosion_radius = explosion_radius;
	proj.explosion_damage = damage;
	proj.global_position = $Head/Barrel/MuzzleFlash.global_position;
	proj.initialize_velocity(time_of_flight, in_range[0].global_position);
	
	return [];
