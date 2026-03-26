/// @func EnemyState_Chase(ctx)
function EnemyState_Chase(_ctx)
{
	if (_ctx.dist > attack_range)
		hsp = move_speed * _ctx.chase_dir;
	else
		hsp = 0;
	
	if (idle_break_phase != 0)
		hsp = 0;
	
	Enemy_HorizontalResolve();
	Enemy_VerticalResolve();
	Enemy_UpdateLocomotionAnim();
}
