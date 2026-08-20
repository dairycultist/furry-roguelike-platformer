extends CharacterBody3D

func _physics_process(delta: float) -> void:

	global_rotation.y += Input.get_axis("turn_left", "turn_right") * delta;

	var direction := Input.get_vector("player_left", "player_right", "player_up", "player_down");
	
	velocity = global_basis * Vector3(direction.x, 0, direction.y) * 5.0;
	velocity.y = -1.0;

	move_and_slide();
