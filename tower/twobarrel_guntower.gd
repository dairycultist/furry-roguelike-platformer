extends Tower;

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
		
	barrel_alternator = not barrel_alternator;
	
	return [in_range[0]];
