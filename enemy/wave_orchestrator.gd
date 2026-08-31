extends Node3D;

const enemy_prefab := preload("res://enemy/enemy.tscn");
const enemy_flying_prefab := preload("res://enemy/enemy_flying.tscn");

@export var _enemy_path : Node3D;

var wave : int = 0;
var wave_active : bool = false:
	set(value):
		wave_active = value;
		$StartWaveLabel.visible = not value;
		if wave_active:
			$WaveLabel.text = str("Wave ", wave);
		else:
			$WaveLabel.text = str("Wave ", wave + 1, " pending");

var spawn_cooldown : float;

func _process(delta: float) -> void:
	
	var size := 1.0 + 0.03 * sin(Time.get_ticks_msec() / 150.0);
	$StartWaveLabel.offset_transform_scale = Vector2(size, size);
	
	if wave_active:
		
		spawn_cooldown -= delta;
		
		if spawn_cooldown < 0.0:
			
			spawn_cooldown = 1.0;
			
			var enemy := (enemy_prefab if randi_range(0, 1) else enemy_flying_prefab).instantiate();
			_enemy_path.add_child(enemy);
	
	else:
		
		if Input.is_action_just_pressed("start_wave"):
		
			wave += 1;
			wave_active = true;
			print("next wave!");
