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

instance_destroy();
