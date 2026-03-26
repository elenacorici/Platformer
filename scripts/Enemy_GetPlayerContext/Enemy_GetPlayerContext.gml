/// @func Enemy_GetPlayerContext()
/// @desc Context despre player pentru AI (apelat din oEnemy Step; self = inamicul).
function Enemy_GetPlayerContext()
{
	var _same_level_max = (wall_tile_height * 0.5) + same_level_slack;
	var _can_see_player = false;
	var _chase_dir = 1;
	var _dist = 999999;
	var _floor_toward_player = false;
	
	if (instance_exists(oPlayer))
	{
		_dist = point_distance(x, y, oPlayer.x, oPlayer.y);
		_chase_dir = sign(oPlayer.x - x);
		if (_chase_dir == 0)
			_chase_dir = 1;
		_floor_toward_player = place_meeting(x + _chase_dir * check_distance, y + 1, oWall);
		_can_see_player = (_dist < sight_range && abs(y - oPlayer.y) < _same_level_max && grounded);
	}
	
	return {
		same_level_max: _same_level_max,
		can_see_player: _can_see_player,
		chase_dir: _chase_dir,
		dist: _dist,
		floor_toward_player: _floor_toward_player
	};
}
