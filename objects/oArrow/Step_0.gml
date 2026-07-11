if (is_stuck) {
	image_angle = stuck_angle; // mentine unghiul inghetat

	if (stuck_target != noone && instance_exists(stuck_target)) {
		x = stuck_target.x + stuck_offset_x;
		y = stuck_target.y + stuck_offset_y;
	} else if (stuck_target != noone) {
		is_stuck      = false;
		stuck_target  = noone;
		speed         = 1;
		direction     = 270; // cade drept in jos
		arrow_gravity = 0.3;
	}

	stuck_timer--;
	if (stuck_timer <= 0)
		instance_destroy();
} else {
	// Homing usor spre tinta blocata (doar sageata centrala, cu calcul
	// balistic — vezi PlayerState_BowAttack.gml/_spawn_arrow). Traiectoria
	// balistica se calculeaza o SINGURA DATA la tragere, spre pozitia tintei
	// din acel moment — daca Ielea se misca in zbor, sageata ajungea la
	// pozitia veche (goala) sau lovea o alta Ielă din apropiere, lasand
	// tinta blocata (bow_target) intacta, desi "ceva" a luat damage.
	// Corectie treptata (nu snap instant), ca sa ramana loc de eschivare.
	if (homing_target != noone) {
		if (instance_exists(homing_target)
		&&  !(variable_instance_exists(homing_target, "is_dead") && homing_target.is_dead)) {
			var _cur_dir = point_direction(0, 0, hspeed, vspeed);
			var _want_dir = point_direction(x, y, homing_target.x, homing_target.y);
			var _delta    = angle_difference(_want_dir, _cur_dir);
			var _new_dir  = _cur_dir + clamp(_delta, -4, 4); // max 4 grade/frame
			var _spd_mag  = point_distance(0, 0, hspeed, vspeed);
			hspeed = lengthdir_x(_spd_mag, _new_dir);
			vspeed = lengthdir_y(_spd_mag, _new_dir);
		} else {
			homing_target = noone; // tinta a murit/disparut — zboara drept in continuare
		}
	}

	if (arrow_gravity > 0) {
		vspeed   += arrow_gravity;
		direction = point_direction(0, 0, hspeed, vspeed);
	}

	image_angle = direction + 180;

	if (x < -32 || x > room_width + 32 || y < -32 || y > room_height + 32)
		instance_destroy();
}
