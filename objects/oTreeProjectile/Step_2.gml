/// @description Step End - gravitație, rotație și coliziune perete
vsp += grv;
x += hsp;
y += vsp;
image_angle += 1.5 * sign(hsp);

if (place_meeting(x, y, oWall))
{
	instance_destroy();
}
