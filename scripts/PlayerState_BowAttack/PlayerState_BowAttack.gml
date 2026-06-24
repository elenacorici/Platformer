function PlayerState_BowAttack() {
	hsp = 0;

	vsp += grv;
	if (place_meeting(x, y + vsp, oWall)) {
		while (!place_meeting(x, y + sign(vsp), oWall))
			y += sign(vsp);
		vsp = 0;
	} else {
		y += vsp;
	}

	// Directie spre target sau drept inainte
	var _sx = x + 15 * image_xscale;
	var _sy = y - 34;

	if (bow_target != noone && instance_exists(bow_target)) {
		bow_aim_dir   = point_direction(_sx, _sy, bow_target.x, bow_target.y);
		image_xscale  = (bow_target.x > x) ? -1 : 1;
	} else {
		bow_aim_dir = (image_xscale < 0) ? 0 : 180;
	}

	// Clamp max 70 grade sub orizontala
	var _aim_sin   = sin(degtorad(bow_aim_dir));
	var _limit_sin = -sin(degtorad(70));
	if (_aim_sin < _limit_sin) {
		var _aim_cos = cos(degtorad(bow_aim_dir));
		var _ccos    = (abs(_aim_cos) < 0.01) ? (-image_xscale * cos(degtorad(70))) : (sign(_aim_cos) * cos(degtorad(70)));
		bow_aim_dir  = radtodeg(arctan2(_limit_sin, _ccos));
		if (bow_aim_dir < 0) bow_aim_dir += 360;
	}

	// Initializare la intrarea in state
	if (sprite_index != sPlayerBowA1Charge
	&&  sprite_index != sPlayerBowA1Hold
	&&  sprite_index != sPlayerBowA1Release) {
		sprite_index     = sPlayerBowA1Charge;
		image_index      = 0;
		image_speed      = 0.15;
		bow_phase        = "draw";
		bow_charge_timer = 0;
		bow_charge_level = 0;
	}

	// --- DRAW ---
	if (bow_phase == "draw") {
		sprite_index = sPlayerBowA1Charge;
		image_speed  = 0.15;

		if (!key_bow) {
			var _prog = image_index / max(1, sprite_get_number(sPlayerBowA1Charge) - 1);
			bow_charge_level = (_prog >= 0.35) ? 1 : 0;
			bow_phase    = "release";
			sprite_index = sPlayerBowA1Release;
			image_index  = 0;
			image_speed  = 0.4;
			_spawn_arrow();

	// --- HOLD ---
	} else if (animation_end()) {
			bow_charge_level = 1;
			bow_phase        = "hold";
			bow_charge_timer = 0;
		}

	} else if (bow_phase == "hold") {
		sprite_index = sPlayerBowA1Hold;
		image_speed  = 0.07;
		bow_charge_timer++;
		if (bow_charge_timer >= 60) bow_charge_level = 2;

		if (!key_bow) {
			bow_phase    = "release";
			sprite_index = sPlayerBowA1Release;
			image_index  = 0;
			image_speed  = 0.4;
			_spawn_arrow();
		}

	// --- RELEASE ---
	} else if (bow_phase == "release") {
		sprite_index = sPlayerBowA1Release;
		image_speed  = 0.4;
		if (animation_end()) {
			bow_phase        = "draw";
			bow_charge_timer = 0;
			bow_charge_level = 0;
			state            = PLAYERSTATE.FREE;
		}
	}
}

function _spawn_arrow() {
	var _sx = x + 15 * image_xscale;
	var _sy = y - 34;

	var _spd, _dmg, _grav;
	switch (bow_charge_level) {
		case 0: _spd = 3;  _dmg = 0; _grav = 0.4;  break; // fail
		case 1: _spd = 6;  _dmg = 1; _grav = 0.15; break; // normal
		case 2: _spd = 10; _dmg = 2; _grav = 0.15; break; // full
	}

	var _dir = bow_aim_dir;

	// Calcul balistic cand exista target locked
	if (bow_target != noone && instance_exists(bow_target) && bow_charge_level > 0) {
		var _dx      = bow_target.x - _sx;
		var _adx     = abs(_dx); // folosim valoarea absoluta in formula
		var _dy_math = -(bow_target.y - _sy);
		var _g       = _grav;
		var _v       = _spd;
		var _disc    = _v*_v*_v*_v - _g * (_g*_adx*_adx + 2*_dy_math*_v*_v);

		if (_disc >= 0 && _adx > 2) {
			// Target reachable - low arc, unghi pozitiv = sus
			var _tan_low = (_v*_v - sqrt(_disc)) / (_g * _adx);
			var _ang     = radtodeg(arctan(_tan_low)); // unghi fata de orizontala (pozitiv = sus)
			_dir = (_dx >= 0) ? _ang : (180 - _ang);
			if (_dir < 0) _dir += 360;
		} else {
			// Target prea departe = fail
			bow_charge_level = 0;
			_spd  = 3;
			_dmg  = 0;
			_grav = 0.4;
			_dir  = bow_aim_dir;
		}
	}

	var _a           = instance_create_layer(_sx, _sy, layer, oArrow);
	_a.direction     = _dir;
	_a.speed         = _spd;
	_a.arrow_dmg     = _dmg;
	_a.image_angle   = _dir + 180;
	_a.arrow_gravity = _grav;
}
