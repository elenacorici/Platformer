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
	if (arrow_gravity > 0) {
		vspeed   += arrow_gravity;
		direction = point_direction(0, 0, hspeed, vspeed);
	}

	image_angle = direction + 180;

	if (x < -32 || x > room_width + 32 || y < -32 || y > room_height + 32)
		instance_destroy();
}
