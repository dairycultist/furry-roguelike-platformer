extends Node3D

@export var ZOOM_SPEED := 10.0;
@export var PAN_SPEED_MULT := 0.8;
@export var PAN_SPEED_SLOW_MULT := 0.4;

var velocity : Vector3

func _process(delta: float) -> void:
	
	var camalt := Input.get_axis("camalt_negative", "camalt_positive");
	var pan := Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down");
	
	if (Input.is_action_pressed("modify_action")):
		
		$Camera.size = clamp($Camera.size + camalt * ZOOM_SPEED * delta, 6.0, 20.0);
		
		if (pan):
			velocity = global_basis * Vector3(pan.x, 0, pan.y) * $Camera.size * PAN_SPEED_SLOW_MULT;
		else:
			velocity = lerp(velocity, Vector3.ZERO, 10.0 * delta);
		
	else:
		
		global_rotation.y += camalt * delta;
		
		if (pan):
			velocity = global_basis * Vector3(pan.x, 0, pan.y) * $Camera.size * PAN_SPEED_MULT;
		else:
			velocity = lerp(velocity, Vector3.ZERO, 10.0 * delta);

	global_position += velocity * delta;
