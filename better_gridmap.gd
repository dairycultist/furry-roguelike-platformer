extends GridMap
class_name BetterGridMap

# 0, 22, 10, 16

class MergeGroup:
	
	var solo;
	var full;
	var side;
	var corner;
	
	@warning_ignore("shadowed_variable")
	func _init(solo, full, side, corner):
		
		self.solo = solo;
		self.full = full;
		self.side = side;
		self.corner = corner;

var CELL_TYPES : Dictionary = {
	"": -1,
	"wall": MergeGroup.new(1, 1, 1, 1)
};

func set_cell(pos: Vector3i, type: String):
	set_cell_item(pos, 1);
