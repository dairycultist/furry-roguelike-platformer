extends Node3D;

var tower_packed_scene_to_example = {};
var base_tower_examples : Array[Tower] = [];

@export var grid : GridMap;
@export var enemy_path : Path3D;
@export var tower_parent : Node3D;

@export var ZOOM_SPEED := 10.0;
@export var PAN_SPEED_MULT := 0.8;
@export var PAN_SPEED_SLOW_MULT := 0.4;

var money : int:
	set(value):
		money = value;
		$InfoBox/MoneyLabel.text = str("$", money);

var towers_by_position = {};

func _create_example_for(packed_scene: PackedScene):
	
	var example := packed_scene.instantiate();
	example.process_mode = Node.PROCESS_MODE_DISABLED;
	tower_packed_scene_to_example[packed_scene] = example;

func _ready() -> void:
	
	_create_example_for(load("res://tower/cannon1/cannon1.tscn"));
	_create_example_for(load("res://tower/sniper1/sniper1.tscn"));
	_create_example_for(load("res://tower/omnigun1/omnigun1.tscn"));
	_create_example_for(load("res://tower/mortar1/mortar1.tscn"));
	
	base_tower_examples = [
		tower_packed_scene_to_example[load("res://tower/cannon1/cannon1.tscn")],
		tower_packed_scene_to_example[load("res://tower/sniper1/sniper1.tscn")],
		tower_packed_scene_to_example[load("res://tower/omnigun1/omnigun1.tscn")],
		tower_packed_scene_to_example[load("res://tower/mortar1/mortar1.tscn")]
	];
	
	money = 5000;

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
			
			var selected_tower : Tower = towers_by_position[selected_pos];
			
			selected_tower.poke();
			
			$Cursor/Mesh.get_surface_override_material(0).albedo_color = Color(0.4, 0.2, 1.0, 0.5);
			
			# tell the tower instance about our list of examples for its upgrades
			if selected_tower.needs_examples:
				
				selected_tower.needs_examples = false;
				
				for packed_scene in selected_tower.upgrade_options:
					if not tower_packed_scene_to_example.has(packed_scene):
						_create_example_for(packed_scene);
					selected_tower.upgrade_options_examples.push_back(tower_packed_scene_to_example[packed_scene]);
			
			run_tower_placement_options(selected_pos, selected_tower, selected_tower.upgrade_options_examples);
			
		else:
			$Cursor/Mesh.get_surface_override_material(0).albedo_color = Color(1.0, 0.2, 0.2, 0.5);
			run_tower_placement_options(selected_pos, null, []);
	else:
		$Cursor/Mesh.get_surface_override_material(0).albedo_color = Color(0.1, 0.6, 1.0, 0.5);
		run_tower_placement_options(selected_pos, null, base_tower_examples);
	
	# move cursor to selection
	$Cursor.global_position = lerp($Cursor.global_position, Vector3(selected_pos) + Vector3(0.5, 0.0, 0.5), 15.0 * delta);

func run_tower_placement_options(selected_pos : Vector3i, selected_tower : Tower, options : Array[Tower]):
	
	$InfoBox/TowerTypeLabel.text = "";
	
	for i in range(0, options.size()):
		$InfoBox/TowerTypeLabel.text += str("[color=white]" if options[i].cost <= money else "[color=gray]", i + 1, " - Upgrade to " if selected_tower else " - Place ", options[i].title, " ($", options[i].cost, ")", "[/color]", "\n");
	
	if selected_tower:
		
		$InfoBox/TowerTypeLabel.text += str(4, " - Sell ($", selected_tower.sell_value, ")\n");
		
		if Input.is_action_just_pressed("tool_4"):
			
			# sell it
			money += selected_tower.sell_value;
			grid.set_cell_item(selected_pos, -1);
			towers_by_position[selected_pos] = null;
			selected_tower.queue_free();

	# placing tower
	if Input.is_action_just_pressed("tool_any"):
		
		var selected_option;
		
		if Input.is_action_just_pressed("tool_1"):
			if options.size() < 1:
				return;
			selected_option = options[0];
		elif Input.is_action_just_pressed("tool_2"):
			if options.size() < 2:
				return;
			selected_option = options[1];
		elif Input.is_action_just_pressed("tool_3"):
			if options.size() < 3:
				return;
			selected_option = options[2];
		else:
			if options.size() < 4:
				return;
			selected_option = options[3];
		
		# perform money
		if selected_option.cost > money:
			return;
		
		money -= selected_option.cost;
		
		# instance the selected tower
		var tower = selected_option.duplicate();
		
		tower_parent.add_child(tower);
		tower.process_mode = Node.PROCESS_MODE_ALWAYS;
		tower.enemy_path = enemy_path;
		tower.global_position = Vector3(selected_pos.x + 0.5, 0.0, selected_pos.z + 0.5);
		
		if selected_tower:
			# delete original tower at this position
			selected_tower.queue_free();
		else:
			# occupy the cell at this position
			grid.set_cell_item(selected_pos, 0);
		
		# register this tower at this position
		towers_by_position[selected_pos] = tower;
