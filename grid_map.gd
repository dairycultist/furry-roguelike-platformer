extends GridMap;

@export var occupied_material : Material;

func _ready() -> void:
	occupied_material.albedo_color = Color(0.0, 0.0, 0.0, 0.0);
