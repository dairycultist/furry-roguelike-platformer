extends Node3D;

var cannon_example : Tower;
var sniper_example : Tower;
var omnigun_example : Tower;
var mortar_example : Tower;

@export var ZOOM_SPEED := 10.0;
@export var PAN_SPEED_MULT := 0.8;
@export var PAN_SPEED_SLOW_MULT := 0.4;

var money : int:
	set(value):
		money = value;
		$InfoBox/MoneyLabel.text = str("$", money);

var grid : GridMap;
var enemy_path : Path3D;
var tower_parent : Node3D;

var towers_by_position = {};

func _ready() -> void:
	
	cannon_example = load("res://tower/cannon/cannon1.tscn").instantiate();
	cannon_example.process_mode = Node.PROCESS_MODE_DISABLED;
	
	sniper_example = load("res://tower/sniper/sniper1.tscn").instantiate();
	sniper_example.process_mode = Node.PROCESS_MODE_DISABLED;
	
	omnigun_example = load("res://tower/omnigun/omnigun1.tscn").instantiate();
	omnigun_example.process_mode = Node.PROCESS_MODE_DISABLED;
	
	mortar_example = load("res://tower/mortar/mortar1.tscn").instantiate();
	mortar_example.process_mode = Node.PROCESS_MODE_DISABLED;
	
	money = 50;
	
	grid = get_parent();
	enemy_path = grid.get_node("EnemyPath");
	tower_parent = grid.get_node("TowerParent");

func _process(delta: float) -> void:
	
	# navigation
	var camalt := Input.get_axis("camalt_negative", "camalt_positive");
	var pan := Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down");
	
	var velocity : Vector3;
	
	if (Input.is_action_pressed("modify_action")):
		$CameraAnchor/Camera.size = clamp($CameraAnchor/Camera.size + camalt * ZOOM_SPEED * delta, 6.0, 20.0);
		velocity = $CameraAnchor.global_basis * Vector3(pan.x, 0, pan.y) * $CameraAnchor/Camera.size * PAN_SPEED_SLOW_MULT;
	else:
		$CameraAnchor.global_rotation.y += camalt * delta;
		velocity = $CameraAnchor.global_basis * Vector3(pan.x, 0, pan.y) * $CameraAnchor/Camera.size * PAN_SPEED_MULT;

	# center on tile if not actively moving
	if not pan:
		velocity = Vector3(
			0.5 - fposmod(global_position.x, 1.0),
			0.0,
			0.5 - fposmod(global_position.z, 1.0)
		) * 200 * delta;

	# update player position (cursor lags behind and is moved separately)
	var prev_position = global_position;

	global_position += velocity * delta;
	global_position = global_position.clamp(Vector3(-13, 0, -13), Vector3(12, 0, 12));
	
	$Cursor.global_position -= global_position - prev_position;
	
	# selection
	var selected_pos : Vector3i = Vector3i(global_position.floor());
	var pos_occupied : bool = grid.get_cell_item(selected_pos) >= 0;
	
	if pos_occupied:
		
		if towers_by_position.has(selected_pos):
			
			var selected_tower : Node3D = towers_by_position[selected_pos];
			
			selected_tower.poke();
			
			$Cursor/Mesh.get_surface_override_material(0).albedo_color = Color(0.4, 0.2, 1.0, 0.5);
			
			# TODO towers should be able to report an array of what
			# towers they can upgrade to
			run_tower_placement_options(selected_pos, false, []);
			
		else:
			$Cursor/Mesh.get_surface_override_material(0).albedo_color = Color(1.0, 0.2, 0.2, 0.5);
			run_tower_placement_options(selected_pos, true, []);
	else:
		$Cursor/Mesh.get_surface_override_material(0).albedo_color = Color(0.1, 0.6, 1.0, 0.5);
		run_tower_placement_options(selected_pos, true, [cannon_example, sniper_example, omnigun_example, mortar_example]);
	
	# move cursor to selection
	$Cursor.global_position = lerp($Cursor.global_position, Vector3(selected_pos) + Vector3(0.5, 0.0, 0.5), 15.0 * delta);

func run_tower_placement_options(selected_pos : Vector3i, place_otherwise_upgrade : bool, types : Array[Tower]):
	
	$InfoBox/TowerTypeLabel.text = "";
	
	for i in range(0, types.size()):
		$InfoBox/TowerTypeLabel.text += str("[color=white]" if types[i].cost <= money else "[color=gray]", i + 1, " - Place " if place_otherwise_upgrade else " - Upgrade to ", types[i].title, " ($", types[i].cost, ")", "[/color]", "\n");
	
	if not place_otherwise_upgrade:
		$InfoBox/TowerTypeLabel.text += str(4, " - Destroy (no workie)\n");

	# placing tower
	if Input.is_action_just_pressed("tool_any"):
		
		if place_otherwise_upgrade:
		
			var tower_type;
			
			if Input.is_action_just_pressed("tool_1"):
				if types.size() < 1:
					return;
				tower_type = types[0];
			elif Input.is_action_just_pressed("tool_2"):
				if types.size() < 2:
					return;
				tower_type = types[1];
			elif Input.is_action_just_pressed("tool_3"):
				if types.size() < 3:
					return;
				tower_type = types[2];
			else:
				if types.size() < 4:
					return;
				tower_type = types[3];
			
			if tower_type.cost > money:
				return;
			
			money -= tower_type.cost;
			
			var tower = tower_type.duplicate();
			
			tower_parent.add_child(tower);
			tower.process_mode = Node.PROCESS_MODE_ALWAYS;
			tower.enemy_path = enemy_path;
			tower.global_position = Vector3(selected_pos.x + 0.5, 0.0, selected_pos.z + 0.5);
			
			grid.set_cell_item(selected_pos, 0);
			
			towers_by_position[selected_pos] = tower;
