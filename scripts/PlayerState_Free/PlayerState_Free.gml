function PlayerState_Free(){
	vsp += grv;
	var on_ground = place_meeting(x, y + 1, oWall);
	
	var _key_a = keyboard_check(ord("A"));
	var _key_d = keyboard_check(ord("D"));
	var _s_held = keyboard_check(ord("S"));
	var _s_pressed = keyboard_check_pressed(ord("S"));
	var _a_pressed = keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left);
	var _d_pressed = keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right);
	
	// Roll: S apăsat + A/D/săgeți SAU din crouch: S ținut + A/D/săgeți apăsat
	var want_roll = false;
	if (roll_timer <= 0 && on_ground)
	{
		want_roll = (_s_pressed && (_key_a || _key_d))
			|| (_s_held && (_a_pressed || _d_pressed));
	}
	
	is_crouching = (roll_timer <= 0) && on_ground && _s_held && !_key_a && !_key_d;
	
	// --- Roll (tot în FREE): intrare doar pe podea
	if (want_roll)
	{
		if (_s_pressed && (_key_a || _key_d))
		{
			if (_key_a && !_key_d)
				roll_dir = -1;
			else if (_key_d && !_key_a)
				roll_dir = 1;
			else
				roll_dir = _key_d ? 1 : -1;
		}
		else
		{
			if (_a_pressed && !_d_pressed)
				roll_dir = -1;
			else if (_d_pressed && !_a_pressed)
				roll_dir = 1;
			else
				roll_dir = _d_pressed ? 1 : -1;
		}
		
		roll_timer = roll_duration;
		image_index = 0;
		image_xscale = -roll_dir;
	}
	
	// --- Mișcare roll
	if (roll_timer > 0)
	{
		hsp = 0;
		
		var _dir = roll_dir;
		for (var _i = 0; _i < roll_speed; _i++)
		{
			if (!place_meeting(x + _dir, y, oWall))
				x += _dir;
			else
				break;
		}
		
		if (place_meeting(x, y + vsp, oWall))
		{
			while (!place_meeting(x, y + sign(vsp), oWall))
				y += sign(vsp);
			vsp = 0;
		}
		else
			y += vsp;
		
		sprite_index = sPlayerRoll;
		image_speed = 1;
		
		if (animation_end())
			roll_timer = 0;
		else if (roll_timer > 0)
			roll_timer--;
	}
	else
	{
		// --- Mișcare normală
		var move = key_right - key_left;
		hsp = is_crouching ? 0 : (move * walksp);
		
		if (on_ground)
			jumps_left = jumps_max;
		
		if (key_jump_pressed && jumps_left > 0 && roll_timer <= 0)
		{
			vsp = -3;
			jumps_left--;
			if (jumps_left == 0)
				part_particles_create(p_sys, x, y, p_dust, 15);
		}
		
		//Horizontal Collision
		if (hsp != 0)
		{
			var already_colliding = place_meeting(x, y, oWall);
			
			if (place_meeting(x + hsp, y, oWall))
			{
				if (already_colliding)
				{
					var test_pos = x + hsp * 2;
					if (!place_meeting(test_pos, y, oWall))
						x = x + hsp;
					else
					{
						while (!place_meeting(x + sign(hsp), y, oWall))
							x = x + sign(hsp);
						hsp = 0;
					}
				}
				else
				{
					while (!place_meeting(x + sign(hsp), y, oWall))
						x = x + sign(hsp);
					hsp = 0;
				}
			}
			else
				x = x + hsp;
		}
		
		//Vertical Collision
		if (place_meeting(x, y + vsp, oWall))
		{
			while (!place_meeting(x, y + sign(vsp), oWall))
				y = y + sign(vsp);
			vsp = 0;
		}
		else
			y = y + vsp;
		
		//Animation
		if (!place_meeting(x, y + 1, oWall))
		{
			image_speed = 1;
			sprite_index = sPlayerJ;
		}
		else if (is_crouching)
		{
			sprite_index = sPlayerC;
			if (!was_crouching)
				image_index = 0;
			
			if (image_index < 3)
				image_speed = 0.3;
			else
			{
				image_index = 3;
				image_speed = 0;
			}
		}
		else
		{
			image_speed = 1;
			if (was_crouching && !is_crouching && sprite_index == sPlayerC)
				image_index = 0;
			
			if (sign(hsp) == 0)
				sprite_index = sPlayer;
			else
				sprite_index = sPlayerR;
		}
		
		if (sign(hsp) != 0)
			image_xscale = -sign(hsp);
	}
	
	was_crouching = is_crouching;
	
	if (keyAttack && roll_timer <= 0 && !is_crouching)
		state = PLAYERSTATE.ATTACK_SLASH;
}
