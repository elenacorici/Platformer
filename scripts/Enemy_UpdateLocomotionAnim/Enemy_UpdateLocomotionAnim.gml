/// @func Enemy_UpdateLocomotionAnim()
/// @desc PATROL / CHASE: mers, idle, săritură (nu ATTACK). Ramuri pe tip obiect.
function Enemy_UpdateLocomotionAnim()
{
	if (Enemy_IsWolfEnemy())
	{
		if (!place_meeting(x, y + 1, oWall))
		{
			if (idle_break_phase != 0)
			{
				idle_break_phase = 0;
				idle_break_breath_timer = 0;
			}
			grounded = false;
			image_speed = 0.25;
			sprite_index = sWolfR;
		}
		else if (idle_break_phase == 1)
		{
			grounded = true;
			sprite_index = sWolf;
			var _idle_m = (state == ENEMYSTATE.PATROL) ? idle_patrol_idle_anim_mult : 1;
			image_speed = idle_breath_image_speed * _idle_m;
		}
		else if (idle_break_phase == 2)
		{
			grounded = true;
			sprite_index = sWolf;
			var _idle_m2 = (state == ENEMYSTATE.PATROL) ? idle_patrol_idle_anim_mult : 1;
			image_speed = idle_scratch_image_speed * _idle_m2;
		}
		else
		{
			grounded = true;
			image_speed = 0.25;
			if (sign(hsp) == 0)
				sprite_index = sWolf;
			else
				sprite_index = sWolfR;
		}
		
		if (idle_break_phase == 2 && sprite_index == sWolf && animation_end())
		{
			idle_break_phase = 0;
			idle_break_cooldown = irandom_range(idle_break_cooldown_min, idle_break_cooldown_max);
			image_index = 0;
		}
		return;
	}
	
	// oEnemy clasic
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
		var _idle_m = (state == ENEMYSTATE.PATROL) ? idle_patrol_idle_anim_mult : 1;
		image_speed = idle_breath_image_speed * _idle_m;
	}
	else if (idle_break_phase == 2)
	{
		grounded = true;
		sprite_index = sEnemyI;
		var _idle_m2 = (state == ENEMYSTATE.PATROL) ? idle_patrol_idle_anim_mult : 1;
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
