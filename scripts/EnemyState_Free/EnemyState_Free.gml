/// @func EnemyState_Free()
function EnemyState_Free()
{
	hsp = patrol_move_speed * patrol_dir;
	if (idle_break_phase != 0)
		hsp = 0;
	
	Enemy_HorizontalResolve();
	Enemy_VerticalResolve();
	Enemy_UpdateLocomotionAnim();
}
