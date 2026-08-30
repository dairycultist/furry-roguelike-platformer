extends PathFollow3D;

@export var _speed : float = 1.0;
@export var _health : int = 3;
@export var _money_value : int = 10;

var _hit_fac : float = 1.0;

var _material : ShaderMaterial;

func _ready() -> void:
	_material = $Mesh.get_surface_override_material(0).duplicate();
	$Mesh.set_surface_override_material(0, _material);

func attack(dmg : int) -> void:
	_hit_fac = 0.0;
	_health -= dmg;
	$Mesh.position = 0.25 * Vector3(randfn(0, 1), 0.0, randfn(0, 1)).normalized();
	if _health <= 0:
		get_parent().alert_enemy_defeated(_money_value);
		queue_free();

func _process(delta: float) -> void:
	_material.set_shader_parameter("hit_fac", _hit_fac);
	_hit_fac = min(1.0, _hit_fac + 2.0 * delta);
	progress += _speed * delta;
	$Mesh.position = lerp($Mesh.position, Vector3.ZERO, 3.0 * delta);
