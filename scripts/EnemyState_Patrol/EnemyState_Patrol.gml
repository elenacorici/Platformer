/// @func EnemyState_Patrol()
/// @desc Patrulare (fost FREE): viteză patrol, idle la margine, animație unificată.
function EnemyState_Patrol()
{
	hsp = patrol_move_speed * patrol_dir;
	if (idle_break_phase != 0)
		hsp = 0;
	
	Enemy_HorizontalResolve();
	Enemy_VerticalResolve();
	Enemy_UpdateLocomotionAnim();
}
