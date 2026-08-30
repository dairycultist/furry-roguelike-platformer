extends Path3D;

@export var _player : Node3D;

## Enemies use this function by calling it on their parent, which
## should have this script.
func alert_enemy_defeated(enemy_money_value : int):
	_player.money += enemy_money_value;
