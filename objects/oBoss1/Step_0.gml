vsp += grv;

Enemy_VerticalResolve();

if (state == "idle" && place_meeting(x, y + 1, oWall))
	image_speed = idle_image_speed;

image_xscale = facing * boss_scale;
image_yscale = boss_scale;
