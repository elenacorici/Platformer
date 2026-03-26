/// @description Verifică dacă lipsește copacul și îl replantă după delay
var _near = instance_nearest(plant_x, plant_y, oTree);
if (_near == noone || point_distance(plant_x, plant_y, _near.x, _near.y) > 80)
{
	spawn_timer++;
	if (spawn_timer >= spawn_delay)
	{
		spawn_timer = 0;
		instance_create_layer(plant_x, plant_y, "Enemies", oTree);
	}
}
else
	spawn_timer = 0;
