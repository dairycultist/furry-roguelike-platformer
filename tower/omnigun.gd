extends Tower;

func _process(delta: float) -> void:
	super._process(delta);
	
	# revert animation
	$Head/Barrel.scale = lerp($Head/Barrel.scale, Vector3.ONE, 5.0 * delta);
	$Head/Barrel/MuzzleFlash.scale = lerp($Head/Barrel/MuzzleFlash.scale, Vector3.ZERO, 3.0 * delta);

func pick_target_to_face(_in_range : Array[Node3D]) -> Node3D:
	return null;

func pick_targets_to_attack(in_range : Array[Node3D]) -> Array[Node3D]:
	
	# fire animation
	$Head/Barrel.scale = Vector3(0.8, 1.2, 0.8);
	$Head/Barrel/MuzzleFlash.scale = Vector3(1.0, 1.0, 1.0);
	
	return in_range;
