@abstract
extends Node3D;
class_name Tower;

@export var title : String = "Unnamed Tower";
@export var cost : int = 0;
@export var sell_value : int = 0;

@export var damage : int = 1;
@export var max_targeting_distance : int = 3;
@export var long_range_only : bool = false;
@export var override_targeting_animation : bool = false;

var enemy_path : Node3D;
var fire_cooldown : float;
var poked : bool;

func _process(delta: float) -> void:
	
	if poked:
		poked = false;
	else:
		$Radius.visible = false;
	
	# exhaust cooldown
	if (not fire_cooldown < 0.0):
		fire_cooldown -= delta;
	
	# get targets in range
	var in_range : Array[Node3D] = [];
		
	for enemy in enemy_path.get_children():
		
		var dist = Vector3(enemy.global_position.x, 0.0, enemy.global_position.z).distance_to(global_position);
		
		if dist <= max_targeting_distance + 0.5 and (not long_range_only or dist >= (max_targeting_distance + 0.5) / 2.0):
			in_range.push_back(enemy);
	
	# do stuff with targets
	if not in_range.is_empty():
		
		# targeting animation
		if override_targeting_animation:
			$Head.global_rotation.y += 0.5 * delta;
		else:
			var look_at_target := pick_target_to_face(in_range);
			$Head.look_at(Vector3(look_at_target.global_position.x, global_position.y, look_at_target.global_position.z), Vector3.UP, true);
		
		# fire at target
		if (fire_cooldown < 0.0):
			fire_cooldown = 1.0;
			for enemy in pick_targets_to_attack(in_range):
				enemy.attack(damage, global_position);
	else:
		$Head.global_rotation.y += 0.5 * delta;

func poke():
	poked = true;
	$Radius.size = Vector3(1.0 + max_targeting_distance * 2, 2.0, 1.0 + max_targeting_distance * 2);
	$Radius.visible = true;

## in_range is an array of enemies that are in range, in order from
## front to back.
@abstract func pick_target_to_face(in_range : Array[Node3D]) -> Node3D;

## in_range is an array of enemies that are in range, in order from
## front to back. You don't actually have to return any targets, in
## which case you can handle target attacking yourself.
@abstract func pick_targets_to_attack(in_range : Array[Node3D]) -> Array[Node3D];
