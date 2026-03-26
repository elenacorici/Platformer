/// @func Enemy_UpdateLocomotionAnim()
/// @desc FREE / CHASE: mers, idle, saritura (nu ATTACK).
function Enemy_UpdateLocomotionAnim()
{
	if (!place_meeting(x, y + 1, oWall))
	{
		if (idle_break_phase != 0)
		{
			idle_break_phase = 0;
			idle_break_breath_timer = 0;
		}
		grounded = false;
		image_speed = 0.4;
		sprite_index = sEnemyJ;
	}
	else if (idle_break_phase == 1)
	{
		grounded = true;
		sprite_index = sEnemy;
		var _idle_m = (state == ENEMYSTATE.FREE) ? idle_patrol_idle_anim_mult : 1;
		image_speed = idle_breath_image_speed * _idle_m;
	}
	else if (idle_break_phase == 2)
	{
		grounded = true;
		sprite_index = sEnemyI;
		var _idle_m2 = (state == ENEMYSTATE.FREE) ? idle_patrol_idle_anim_mult : 1;
		image_speed = idle_scratch_image_speed * _idle_m2;
	}
	else
	{
		grounded = true;
		image_speed = 0.4;
		if (sign(hsp) == 0)
			sprite_index = sEnemy;
		else
			sprite_index = sEnemyR;
	}
	
	if (idle_break_phase == 2 && sprite_index == sEnemyI && animation_end())
	{
		idle_break_phase = 0;
		idle_break_cooldown = irandom_range(idle_break_cooldown_min, idle_break_cooldown_max);
		image_index = 0;
	}
}
