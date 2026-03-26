/// @func Enemy_UpdateFacing(ctx)
function Enemy_UpdateFacing(_ctx)
{
	var _face_player = (state == ENEMYSTATE.CHASE) || (state == ENEMYSTATE.ATTACK) || (_ctx.can_see_player);
	if (_face_player && instance_exists(oPlayer))
	{
		var _fx = sign(oPlayer.x - x);
		if (_fx == 0)
			_fx = 1;
		image_xscale = -_fx * size;
	}
	else if (sign(hsp) != 0)
		image_xscale = -sign(hsp) * size;
	else
		image_xscale = -patrol_dir * size;
	image_yscale = size;
}
