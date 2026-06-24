if (is_stuck) exit;

with (other) {
	if (state != "dying" && state != "dead") {
		state        = "dying";
		sprite_index = bat_die;
		image_index  = 0;
		image_speed  = 0.25;
		hspeed       = 0;
		vspeed       = -2;
	}
}

x += lengthdir_x(28, direction);
y += lengthdir_y(28, direction);

speed          = 0;
is_stuck       = true;
stuck_angle    = direction;
stuck_target   = other.id;
stuck_offset_x = x - other.x;
stuck_offset_y = y - other.y;
