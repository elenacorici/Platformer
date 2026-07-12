/// @description Atarnat static -> la apropiere, zboara si pleaca (fara atac)

if (state == "hang")
{
	if (instance_exists(oPlayer) && point_distance(x, y, oPlayer.x, oPlayer.y) < wake_range)
	{
		state        = "fly";
		image_speed  = 0.3;
		// Traiectorie fixa (stanga/dreapta) daca e setata din Instance Creation
		// Code, altfel fuge in directia opusa playerului (implicit)
		fly_dir      = (trajectory != 0)
			? (trajectory < 0 ? 180 : 0)
			: point_direction(oPlayer.x, oPlayer.y, x, y);
	}
}
else // "fly"
{
	x += lengthdir_x(fly_speed, fly_dir);
	y += lengthdir_y(fly_speed, fly_dir);
	image_xscale = (lengthdir_x(1, fly_dir) < 0) ? -1 : 1;

	// Curatare cand iese din room
	if (x < -32 || x > room_width + 32 || y < -32 || y > room_height + 32)
		instance_destroy();
}
