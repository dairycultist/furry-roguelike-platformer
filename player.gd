extends CharacterBody2D

const MAX_CAM_OFF = Vector2(24, 32);

const SPEED = 150.0;
const JUMP_VELOCITY = -500.0;

func _process(delta: float) -> void:
	
	# speen
	$Mesh.rotation.y += delta;
	
	# camera follows player (replicated by moving 2DAnchor as there's no camera)
	# where the player may be offset from the camera's center by up to a fixed amount
	var player_camera_off : Vector2 = (-get_parent().global_position + Vector2(256 / 2, 192 / 2)) - position;
	
	get_parent().global_position = Vector2(256 / 2, 192 / 2) - (player_camera_off.clamp(-MAX_CAM_OFF, MAX_CAM_OFF) + position);
	
	# player mesh follows player
	$Mesh.global_position = Vector3(global_position.x / 16, -global_position.y / 16, 0);

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta;

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY;

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right");
	if direction:
		velocity.x = direction * SPEED;
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED);

	move_and_slide();
