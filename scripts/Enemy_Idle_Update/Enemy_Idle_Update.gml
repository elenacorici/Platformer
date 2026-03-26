/// @func Enemy_Idle_Update(ctx, ledge_dir, skip_near_for_attack_range)
function Enemy_Idle_Update(_ctx, _ledge_dir, _skip_near_for_attack_range)
{
	var _idle_edge_px = check_distance + idle_edge_extra;
	var _at_platform_edge = grounded && !place_meeting(x + _idle_edge_px * _ledge_dir, y + 1, oWall);
	
	if (idle_break_phase == 1)
	{
		idle_break_breath_timer--;
		if (idle_break_breath_timer <= 0)
		{
			if (idle_break_will_scratch)
			{
				idle_break_phase = 2;
				image_index = 0;
			}
			else
			{
				idle_break_phase = 0;
				idle_break_cooldown = irandom_range(idle_break_cooldown_min, idle_break_cooldown_max);
			}
		}
	}
	
	if (idle_break_phase == 0 && idle_break_cooldown <= 0 && grounded
		&& (state == ENEMYSTATE.FREE || state == ENEMYSTATE.CHASE) && _at_platform_edge
		&& random(1) < idle_break_roll_chance_ledge)
	{
		if (!_skip_near_for_attack_range)
		{
			idle_break_phase = 1;
			idle_break_breath_timer = irandom_range(idle_breath_min_frames, idle_breath_max_frames);
			idle_break_will_scratch = (random(1) < idle_scratch_chance);
		}
	}
}
