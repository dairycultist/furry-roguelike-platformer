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

func get_cell(pos: Vector3i) -> String:
	
	var target := get_cell_item(pos);
	
	for key in CELL_TYPES.keys():
		
		var value = CELL_TYPES.get(key);
		
		if value is MergeGroup:
			if value.has_index(target):
				return key;
		elif value == target:
			return key;
	
	return "";

func set_cell(pos: Vector3i, type: String):
	set_cell_item(pos, 1);
