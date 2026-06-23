function PlayerState_BowAttack() {
	hsp = 0;

	// Gravitatie + coliziune verticala
	vsp += grv;
	if (place_meeting(x, y + vsp, oWall)) {
		while (!place_meeting(x, y + sign(vsp), oWall))
			y += sign(vsp);
		vsp = 0;
	} else {
		y += vsp;
	}

	// Player se intoarce spre mouse in tot timpul atacului
	image_xscale = (mouse_x > x) ? -1 : 1;

	// Initializare la intrarea in state (nici un sprite de bow activ)
	if (sprite_index != sPlayerBowA1Charge
	&&  sprite_index != sPlayerBowA1Hold
	&&  sprite_index != sPlayerBowA1Release) {
		sprite_index     = sPlayerBowA1Charge;
		image_index      = 0;
		image_speed      = 0.4;
		bow_phase        = "draw";
		bow_charge_timer = 0;
	}

	// --- DRAW: sPlayerBowA1Charge, ruleaza o singura data ---
	if (bow_phase == "draw") {
		sprite_index = sPlayerBowA1Charge;
		image_speed  = 0.4;
		if (animation_end()) {
			bow_phase        = "hold";
			bow_charge_timer = 0;
		}
	}

	// --- HOLD: sPlayerBowA1Hold loop + sBow_point rotit spre mouse ---
	if (bow_phase == "hold") {
		sprite_index = sPlayerBowA1Hold;
		image_speed  = 0.07;

		bow_charge_timer = min(bow_charge_timer + 1, bow_charge_max);

		// Directia de tintire urmareste mouse-ul in timp real
		var _sx     = x + 15 * image_xscale;
		var _sy     = y - 15 * image_yscale - 2;
		bow_aim_dir = point_direction(_sx, _sy, mouse_x, mouse_y);

		// Clamp: max 70 grade sub orizontala (nu poate pointa direct in jos)
		var _max_below = 70; // grade sub orizontala, ajusteaza dupa preferinta
		var _aim_sin   = sin(degtorad(bow_aim_dir));
		var _limit_sin = -sin(degtorad(_max_below));
		if (_aim_sin < _limit_sin) {
			var _aim_cos = cos(degtorad(bow_aim_dir));
			var _clamped_cos;
			if (abs(_aim_cos) < 0.01)
				_clamped_cos = -image_xscale * cos(degtorad(_max_below));
			else
				_clamped_cos = sign(_aim_cos) * cos(degtorad(_max_below));
			bow_aim_dir = radtodeg(arctan2(_limit_sin, _clamped_cos));
			if (bow_aim_dir < 0) bow_aim_dir += 360;
		}

		// Elibereaza la release buton
		if (!keyAttack_held) {
			var _spd = lerp(5, 10, bow_charge_timer / bow_charge_max);
			var _dmg = (bow_charge_timer >= 20) ? 2 : 1;

			var _a         = instance_create_layer(_sx, _sy, layer, oArrow);
			_a.direction   = bow_aim_dir;
			_a.speed       = _spd;
			_a.arrow_dmg   = _dmg;
			_a.image_angle = bow_aim_dir + 180;

			bow_phase        = "release";
			sprite_index     = sPlayerBowA1Release;
			image_index      = 0;
			image_speed      = 0.4;
			bow_charge_timer = 0;
		}
	}

	// --- RELEASE: sPlayerBowA1Release ruleaza o singura data, apoi FREE ---
	if (bow_phase == "release") {
		sprite_index = sPlayerBowA1Release;
		image_speed  = 0.4;
		if (animation_end()) {
			bow_phase = "draw";
			state     = PLAYERSTATE.FREE;
		}
	}
}
