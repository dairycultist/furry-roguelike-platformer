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

## Returns an array where [0]=Vector3i cell position, [1]=String cell type
func get_cell_data(pos: Vector3) -> Array:
	
	var posi := local_to_map(pos);
	var target := get_cell_item(posi);
	
	# if the target is an occupied cell, we don't want to return that to the
	# caller; instead, we want to return the data of the nearby 3x3 cell
	if (CELL_TYPES.find_key(target) == "occupied"):
		for dx in range(-1, 2):
			for dz in range(-1, 2):
				
				var key: String = _string_id_of_cell_index(get_cell_item(posi + Vector3i(dx, 0, dz)));
				
				# right now monuments are the only >1x1 cells
				if ([ "monument" ].has(key)):
					return [posi + Vector3i(dx, 0, dz), key];
		
		push_error("Failed to find a >1x1 cell by occupied cell at " + str(posi.x) + "," + str(posi.y));
		get_tree().quit();
	
	# find the String identifier that matches the target cell index
	return [posi, _string_id_of_cell_index(target)];

func set_cell(pos: Vector3i, _type: String):
	set_cell_item(pos, 1);
