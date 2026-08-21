extends GridMap
class_name BetterGridMap

class MergeGroup:
	
	var solo;
	var full;
	var side;
	var corner; # TODO
	var end;
	var tube; # TODO
	
	func has_index(index: int) -> bool:
		return index == solo or index == full or index == side or index == corner\
			or index == end or index == tube;
	
	@warning_ignore("shadowed_variable")
	func _init(solo, full, side, corner, end, tube):
		
		self.solo   = solo;
		self.full   = full;
		self.side   = side;
		self.corner = corner;
		self.end    = end;
		self.tube   = tube;

var CELL_TYPES : Dictionary = {
	"": -1,
	"wall": MergeGroup.new(1, 4, 6, 1, 5, 1),
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

func _update_merge_cell(pos: Vector3i, type: String):
	
	# if this isn't the type of cell we expect, don't update it
	if _string_id_of_cell_index(get_cell_item(pos)) != type:
		return;
	
	# get neighborhood booleans
	var top    := _string_id_of_cell_index(get_cell_item(pos + Vector3i(0, 0, 1))) == type;
	var bottom := _string_id_of_cell_index(get_cell_item(pos - Vector3i(0, 0, 1))) == type;
	var left   := _string_id_of_cell_index(get_cell_item(pos - Vector3i(1, 0, 0))) == type;
	var right  := _string_id_of_cell_index(get_cell_item(pos + Vector3i(1, 0, 0))) == type;
	var count = 0;
	
	if top:    count += 1;
	if bottom: count += 1;
	if left:   count += 1;
	if right:  count += 1;
	
	if count == 0:
		set_cell_item(pos, CELL_TYPES.get(type).solo);
	elif count == 1:
		if top:
			set_cell_item(pos, CELL_TYPES.get(type).end, 16);
		elif bottom:
			set_cell_item(pos, CELL_TYPES.get(type).end, 22);
		elif right:
			set_cell_item(pos, CELL_TYPES.get(type).end, 10);
		else:
			set_cell_item(pos, CELL_TYPES.get(type).end, 0);
	elif count == 3:
		if !top:
			set_cell_item(pos, CELL_TYPES.get(type).side, 22);
		elif !bottom:
			set_cell_item(pos, CELL_TYPES.get(type).side, 16);
		elif !right:
			set_cell_item(pos, CELL_TYPES.get(type).side, 0);
		else:
			set_cell_item(pos, CELL_TYPES.get(type).side, 10);
	else:
		set_cell_item(pos, CELL_TYPES.get(type).full);

## Sets a cell (without checking its contents; do that yourself with
## can_set_cell), accounting for MergeGroups and 3x3 cells (automatically
## placing/removing the surrounding "occupied" cells).
func set_cell(pos: Vector3i, type: String):
	
	var value = CELL_TYPES.get(type);

	if value is MergeGroup:
		
		set_cell_item(pos, value.full);
		
		_update_merge_cell(pos, type);
		_update_merge_cell(pos + Vector3i(0, 0, 1), type);
		_update_merge_cell(pos - Vector3i(0, 0, 1), type);
		_update_merge_cell(pos - Vector3i(1, 0, 0), type);
		_update_merge_cell(pos + Vector3i(1, 0, 0), type);
		
	elif value == -1:
		
		var to_destroy := _string_id_of_cell_index(get_cell_item(pos));
		
		# if we're destroying a big cell, destroy its surrounding occupied cells
		if is_cell_big(to_destroy):
			set_cell_item(pos + Vector3i( 1, 0,  1), -1);
			set_cell_item(pos + Vector3i( 1, 0,  0), -1);
			set_cell_item(pos + Vector3i( 1, 0, -1), -1);
			set_cell_item(pos + Vector3i( 0, 0,  1), -1);
			set_cell_item(pos + Vector3i( 0, 0, -1), -1);
			set_cell_item(pos + Vector3i(-1, 0,  1), -1);
			set_cell_item(pos + Vector3i(-1, 0,  0), -1);
			set_cell_item(pos + Vector3i(-1, 0, -1), -1);
		
		# destroy that mf
		set_cell_item(pos, -1);
		
		# if we destroyed a merge cell, update the surrounding merge cells
		# of the same type
		if CELL_TYPES.get(to_destroy) is MergeGroup:
			_update_merge_cell(pos + Vector3i(0, 0, 1), to_destroy);
			_update_merge_cell(pos - Vector3i(0, 0, 1), to_destroy);
			_update_merge_cell(pos - Vector3i(1, 0, 0), to_destroy);
			_update_merge_cell(pos + Vector3i(1, 0, 0), to_destroy);
		
	elif is_cell_big(type):
		
		var occupied_value = CELL_TYPES.get("occupied");
		
		set_cell_item(pos + Vector3i( 1, 0,  1), occupied_value);
		set_cell_item(pos + Vector3i( 1, 0,  0), occupied_value);
		set_cell_item(pos + Vector3i( 1, 0, -1), occupied_value);
		set_cell_item(pos + Vector3i( 0, 0,  1), occupied_value);
		set_cell_item(pos, value);
		set_cell_item(pos + Vector3i( 0, 0, -1), occupied_value);
		set_cell_item(pos + Vector3i(-1, 0,  1), occupied_value);
		set_cell_item(pos + Vector3i(-1, 0,  0), occupied_value);
		set_cell_item(pos + Vector3i(-1, 0, -1), occupied_value);
		
	else:
		set_cell_item(pos, value);
