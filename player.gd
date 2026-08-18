extends CharacterBody2D

const CAMERA_DEADZONE_RADIUS = Vector2(24, 32);

const MAX_SPEED = 200.0;
const JUMP_VELOCITY = -350.0;
const ACCELERATION = 350;
const TURN_ACCELERATION = 1000;

func _process(delta: float) -> void:
	
	# speen
	$Mesh.rotation.y += delta;
	
	# camera follows player (replicated by moving 2DAnchor as there's no camera)
	# with a deadzone of CAMERA_DEADZONE_RADIUS
	@warning_ignore("integer_division")
	var player_camera_off : Vector2 = Vector2(256 / 2, 192 / 2) - (get_parent().global_position + position);
	
	player_camera_off = player_camera_off.clamp(-CAMERA_DEADZONE_RADIUS, CAMERA_DEADZONE_RADIUS);
	
	@warning_ignore("integer_division")
	get_parent().global_position = Vector2(256 / 2, 192 / 2) - (player_camera_off + position);
	
	# player mesh follows player
	$Mesh.global_position = Vector3(global_position.x / 16, -global_position.y / 16, 0);

func _physics_process(delta: float) -> void:
	
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta;

	# jumping
	elif Input.is_action_just_pressed("player_jump"):
		velocity.y = JUMP_VELOCITY;

	# running
	var direction := Input.get_axis("player_left", "player_right");
	
	if !direction or sign(direction) == sign(velocity.x):
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, ACCELERATION * delta);
	else:
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, TURN_ACCELERATION * delta);

	move_and_slide();
