if (hp <= 0)
{
	with (instance_create_layer(x, y, layer, oDead))
	{
		sprite_index = sBoss1;
		mask_index = sBoss1;
		image_index = 0;
		direction = other.hitfrom;
		hsp = lengthdir_x(3, direction);
		vsp = lengthdir_y(3, direction) - 2;
		if (sign(hsp) != 0)
			image_xscale = sign(hsp) * other.boss_scale;
		image_yscale = other.boss_scale;
	}
	instance_destroy();
}
