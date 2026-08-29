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

	var prev_position = global_position;

	global_position += velocity * delta;
	
	global_position = global_position.clamp(Vector3(-13, 0, -13), Vector3(12, 0, 12));
	
	$Cursor.global_position -= global_position - prev_position;
	
	# selection
	var selected_pos : Vector3i = Vector3i(global_position);
	var pos_invalid : bool = grid.get_cell_item(selected_pos) >= 0;
	
	$Cursor.get_surface_override_material(0).albedo_color = Color(1.0, 0.2, 0.2, 0.5) if pos_invalid else Color(0.1, 0.6, 1.0, 0.5);
	
	$Cursor.global_position = lerp($Cursor.global_position, Vector3(selected_pos) + Vector3(0.5, 0.0, 0.5), 10.0 * delta);
	
	if Input.is_action_just_pressed("use_tool"):
		print(grid.get_cell_item(selected_pos));
