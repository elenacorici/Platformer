function PlayerState_Free(){

	// ── HORA STUN — playerul pluteste inlauntrul horei ───────────
	if (hora_stunned)
	{
		hsp = 0;

		// Gaseste solul de dedesubt
		var _ground = y;
		for (var _g = 0; _g < 300; _g += 2)
			if (place_meeting(x, y + _g, oWall)) { _ground = y + _g; break; }

		// Tinta: 52px deasupra solului + bob sinusoidal
		var _float_y = _ground - 52 + sin(current_time / 450.0) * 4;
		vsp = clamp((_float_y - y) * 0.12, -3, 3);
		y  += vsp;

		sprite_index = sPlayerI;
		image_speed  = 0.08;
		return;
	}

	vsp += grv;
	var on_ground = place_meeting(x, y + 1, oWall);

	// Controle inversate dupa hora
	if (invert_timer > 0)
	{
	    invert_timer--;
	    if (invert_timer <= 0) controls_inverted = false;
	}

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
		
		sprite_index = (current_weapon == "bow") ? sPlayerBowR : sPlayerRoll;
		image_speed = 1;
		
		if (animation_end())
			roll_timer = 0;
		else if (roll_timer > 0)
			roll_timer--;
	}
	else
	{
		// --- Opinci: timer si activare ---
		if (has_opinci) {
			if (key_sprint && opinci_state == "ready") {
				opinci_state = "active";
				opinci_timer = opinci_active_t;
			}
			if (opinci_state == "active") {
				opinci_timer--;
				if (opinci_timer <= 0) {
					opinci_state = "cooldown";
					opinci_timer = opinci_cooldown_t;
				}
			} else if (opinci_state == "cooldown") {
				opinci_timer--;
				if (opinci_timer <= 0) {
					opinci_state = "ready";
					opinci_timer = 0;
				}
			}
		}

		// --- HSP: hora_pull > pushed > post_push > normal
		var _is_sprinting = (has_opinci && opinci_state == "active");
		var _cur_walksp   = _is_sprinting ? opinci_boost_sp : walksp;

		if (hora_pull)
		{
		    hsp          = sign(hora_pull_x - x) * 2.5;
		    sprite_index = sPlayerI;
		    image_speed  = 0.1;
		}
		else if (pushed_timer > 0)
		{
		    pushed_timer--;
		    hsp = pushed_dir * 2.5;
		    if (pushed_timer <= 0) post_push_timer = 35;
		}
		else if (post_push_timer > 0)
		{
		    post_push_timer--;
		    hsp = pushed_dir * 1.5;
		    if (post_push_timer <= 0) pushed_dir = 0;
		}
		else
		{
		    var move = key_right - key_left;
		    hsp = is_crouching ? 0 : (move * _cur_walksp);
		}
		
		if (on_ground)
		{
			jumps_left = jumps_max;
			fast_falling = false;
		}

		if (key_jump_pressed && jumps_left > 0 && roll_timer <= 0)
		{
			vsp = (jumps_left == jumps_max) ? -4.5 : -3.8;
			jumps_left--;
			if (jumps_left == 0)
				part_particles_create(p_sys, x, y, p_dust, 15);
		}

		// Fast fall: S in aer rupe saritura si trage in jos rapid
		if (!on_ground && _s_pressed)
		{
			vsp = 8;
			fast_falling = true;
		}

		//Horizontal Collision
		if (hsp != 0)
		{
			if (place_meeting(x + hsp, y, oWall))
			{
				while (!place_meeting(x + sign(hsp), y, oWall))
					x += sign(hsp);
				hsp = 0;
			}
			else
				x += hsp;
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
		y = floor(y); // previne y fractionar care cauzeaza false collision

		// Roll automat la aterizare dupa fast fall
		if (fast_falling && place_meeting(x, y + 1, oWall))
		{
			fast_falling = false;
			roll_dir = (sign(hsp) != 0) ? sign(hsp) : -sign(image_xscale);
			if (roll_dir == 0) roll_dir = 1;
			roll_timer = roll_duration;
			image_index = 0;
			image_xscale = -roll_dir;
		}

		//Animation
		var _bow = (current_weapon == "bow");
		var _spr_idle   = _bow ? sPlayerBowI  : sPlayerI;
		var _spr_run    = _bow ? (_is_sprinting ? sPlayerBowRun : sPlayerBowW)
		                       : (_is_sprinting ? sPlayerRun    : sPlayerR);
		var _spr_jump   = _bow ? sPlayerBowJ  : sPlayerJ;
		var _spr_crouch = _bow ? sPlayerBowC  : sPlayerC;

		if (!place_meeting(x, y + 1, oWall))
		{
			image_speed = 1;
			sprite_index = _spr_jump;
		}
		else if (is_crouching)
		{
			sprite_index = _spr_crouch;
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
			if (was_crouching && !is_crouching && (sprite_index == sPlayerC || sprite_index == sPlayerBowC))
				image_index = 0;

			if (sign(hsp) == 0) {
				sprite_index = _spr_idle;
				image_speed = 0.1;
			} else {
				sprite_index = _spr_run;
				image_speed = 1;
			}
		}
		
		// --- Override animatie daca e impins de Iele
		if (pushed_timer > 0)
		{
		    sprite_index  = sPlayerI;
		    image_speed   = 0.1;
		    image_xscale  = (pushed_dir > 0) ? 1 : -1;
		}
		else if (post_push_timer > 0)
		{
		    sprite_index  = sPlayerR;
		    image_speed   = 1;
		    image_xscale  = (pushed_dir > 0) ? -1 : 1;
		}
		else if (sign(hsp) != 0)
		    image_xscale = -sign(hsp);
	}
	
	was_crouching = is_crouching;
	
	// Enter climbing — scara sau creanga ridicata
	if (climb_lock > 0) climb_lock--;
	var _key_up       = keyboard_check(vk_up) || keyboard_check(ord("W"));
	var _can_climb    = false;
	var _grab_branch  = noone;
	if (_key_up && climb_lock <= 0)
	{
		if (instance_place(x, y, oLadder))
			_can_climb = true;
		else
		{
			var _n = instance_number(oBranchBase);
			for (var _i = 0; _i < _n; _i++)
			{
				var _b = instance_find(oBranchBase, _i);
				var _spr    = _b.sprite_index;
				var _half_w = sprite_get_width(_spr) * 0.5 * abs(_b.image_xscale);
				var _top    = _b.y - sprite_get_yoffset(_spr) * abs(_b.image_yscale);
				var _bot    = _b.y + (sprite_get_height(_spr) - sprite_get_yoffset(_spr)) * abs(_b.image_yscale);
				if (abs(x - _b.x) <= _half_w && y >= _top && y <= _bot)
				{
					_can_climb   = true;
					_grab_branch = _b;
					break;
				}
			}
		}
	}
	if (_can_climb)
	{
		if (_grab_branch != noone)
			_grab_branch.shake_timer = max(_grab_branch.shake_timer, 35);
		state      = PLAYERSTATE.CLIMBING;
		vsp        = 0;
		hsp        = 0;
		roll_timer = 0;
		return;
	}

	if (keyAttack && roll_timer <= 0 && !is_crouching && has_axe && current_weapon == "axe")
		state = PLAYERSTATE.ATTACK_SLASH;
	if (key_bow_pressed && roll_timer <= 0 && !is_crouching && has_bow && current_weapon == "bow")
		state = PLAYERSTATE.ATTACK_BOW;
}
