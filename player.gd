extends Node3D;

@export var ZOOM_SPEED := 10.0;
@export var PAN_SPEED_MULT := 0.8;
@export var PAN_SPEED_SLOW_MULT := 0.4;

var velocity : Vector3;

var grid : GridMap;

func _ready() -> void:
	grid = get_parent();

func _process(delta: float) -> void:
	
	# navigation
	var camalt := Input.get_axis("camalt_negative", "camalt_positive");
	var pan := Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down");
	
	if (Input.is_action_pressed("modify_action")):
		
		$CameraAnchor/Camera.size = clamp($CameraAnchor/Camera.size + camalt * ZOOM_SPEED * delta, 6.0, 20.0);
		
		if (pan):
			velocity = $CameraAnchor.global_basis * Vector3(pan.x, 0, pan.y) * $CameraAnchor/Camera.size * PAN_SPEED_SLOW_MULT;
		else:
			velocity = lerp(velocity, Vector3.ZERO, 10.0 * delta);
		
	else:
		
		$CameraAnchor.global_rotation.y += camalt * delta;
		
		if (pan):
			velocity = $CameraAnchor.global_basis * Vector3(pan.x, 0, pan.y) * $CameraAnchor/Camera.size * PAN_SPEED_MULT;
		else:
			velocity = lerp(velocity, Vector3.ZERO, 10.0 * delta);

	global_position += velocity * delta;
	$Corner0.global_position -= velocity * delta;
	$Corner1.global_position -= velocity * delta;
	$Corner2.global_position -= velocity * delta;
	$Corner3.global_position -= velocity * delta;
	
	# selection
	var selected_pos : Vector3i = Vector3i(global_position);
	
	$Corner0.global_position = lerp($Corner0.global_position, Vector3(selected_pos), 10.0 * delta);
	$Corner1.global_position = lerp($Corner1.global_position, Vector3(selected_pos) + Vector3(1.0, 0.0, 0.0), 10.0 * delta);
	$Corner2.global_position = lerp($Corner2.global_position, Vector3(selected_pos) + Vector3(1.0, 0.0, 1.0), 10.0 * delta);
	$Corner3.global_position = lerp($Corner3.global_position, Vector3(selected_pos) + Vector3(0.0, 0.0, 1.0), 10.0 * delta);
	
	if Input.is_action_just_pressed("use_tool"):
		print(grid.get_cell_item(selected_pos));
