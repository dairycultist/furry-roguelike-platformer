extends GridMap
class_name BetterGridMap

# 0, 22, 10, 16

class MergeGroup:
	
	var solo;
	var full;
	var side;
	var corner;
	
	func has_index(index: int) -> bool:
		return index == solo or index == full or index == side or index == corner;
	
	@warning_ignore("shadowed_variable")
	func _init(solo, full, side, corner):
		
		self.solo = solo;
		self.full = full;
		self.side = side;
		self.corner = corner;

var CELL_TYPES : Dictionary = {
	"": -1,
	"wall": MergeGroup.new(1, 1, 1, 1),
	"occupied": 2,
	"monument": 3,
	"gravel": 0
};

func _string_id_of_cell_index(index: int) -> String:
	
	for id in CELL_TYPES.keys():
		
		var to_compare = CELL_TYPES.get(id);
		
		if to_compare is MergeGroup:
			if to_compare.has_index(index):
				return id;
		elif to_compare == index:
			return id;
	
	# return empty on no match
	return "";

func is_cell_big(cell_type: String) -> bool:
	
	return [ "monument" ].has(cell_type);

## Returns an array where [0]=Vector3i cell position, [1]=String cell type.
## Collapses MergeGroups into a single type, and treats 3x3 cell types as a
## single cell.
func get_cell_data(pos: Vector3) -> Array:
	
	var posi := local_to_map(pos);
	var target := get_cell_item(posi);
	
	# if the target is an occupied cell, we don't want to return that to the
	# caller; instead, we want to return the data of the nearby 3x3 cell
	if (CELL_TYPES.find_key(target) == "occupied"):
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				
				var key: String = _string_id_of_cell_index(get_cell_item(posi + Vector3i(dx, 0, dz)));
				
				# right now monuments are the only 3x3 cells
				if (is_cell_big(key)):
					return [posi + Vector3i(dx, 0, dz), key];
		
		print("Failed to find a 3x3 cell next to the occupied cell at (" + str(posi.x) + "," + str(posi.z) + ")");
		get_tree().quit();
	
	# find the String identifier that matches the target cell index
	return [posi, _string_id_of_cell_index(target)];

## Returns true only if the position is empty, and, if the type is a 3x3 cell,
## the surrounding positions are empty too. If type="", will always return true
## unless the position contains an "occupied" cell.
func can_set_cell(pos: Vector3i, type: String) -> bool:
	
	var posi := local_to_map(pos);
	
	if (type == ""):
		return _string_id_of_cell_index(get_cell_item(posi)) != "occupied";
	
	if (is_cell_big(type)):
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				if get_cell_item(posi + Vector3i(dx, 0, dz)) >= 0:
					return false;
		return true;
	else:
		return get_cell_item(posi) < 0;

## 
func set_cell(pos: Vector3i, _type: String):
	set_cell_item(pos, 1);
