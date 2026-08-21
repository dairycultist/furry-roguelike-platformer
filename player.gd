extends Node3D

@export var ZOOM_SPEED := 10.0;
@export var PAN_SPEED_MULT := 0.8;
@export var PAN_SPEED_SLOW_MULT := 0.4;

var velocity : Vector3

func _process(delta: float) -> void:

	var dzoom := Input.get_axis("zoom_in", "zoom_out");

	$Camera.size = clamp($Camera.size + dzoom * ZOOM_SPEED * delta, 6.0, 20.0);

	if (!dzoom):
		global_rotation.y += Input.get_axis("turn_right", "turn_left") * delta;

	var direction_slow := Input.get_vector("pan_left_slow", "pan_right_slow", "pan_up_slow", "pan_down_slow");

	if (direction_slow):
		velocity = global_basis * Vector3(direction_slow.x, 0, direction_slow.y) * $Camera.size * PAN_SPEED_SLOW_MULT;
	else:
		var direction := Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down");
		
		if (direction):
			velocity = global_basis * Vector3(direction.x, 0, direction.y) * $Camera.size * PAN_SPEED_MULT;
		else:
			velocity = lerp(velocity, Vector3.ZERO, 10.0 * delta);
	
	global_position += velocity * delta;
