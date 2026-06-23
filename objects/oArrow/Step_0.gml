if (is_stuck) {
	speed   = 0;
	hspeed  = 0;
	vspeed  = 0;
	stuck_timer--;
	if (stuck_timer <= 0)
		instance_destroy();
} else {
	image_angle = direction;
	if (x < -32 || x > room_width + 32 || y < -32 || y > room_height + 32)
		instance_destroy();
}
