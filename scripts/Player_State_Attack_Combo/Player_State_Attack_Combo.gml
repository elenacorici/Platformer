function PlayerState_Attack_Combo(){
	hsp = 0;
	mask_index = -1;
	
	vsp = vsp + grv;
	
	if (place_meeting(x, y + vsp, oWall))
	{
		while (!place_meeting(x, y + sign(vsp), oWall))
			y += sign(vsp);
		vsp = 0;
	}
	else
		y += vsp;
	
	if (sprite_index != sPlayerA2)
	{
		sprite_index = sPlayerA2;
		image_index = 0;
		ds_list_clear(hitByAttack);
	}
	
	mask_index = sPlayerA2HB;
	attack_dir = image_xscale > 0 ? 180 : 0;
	
	var hitByAttackNow = ds_list_create();
	var hits = instance_place_list(x, y, oEnemy, hitByAttackNow, false);
	hits += instance_place_list(x, y, oEnemyBig, hitByAttackNow, false);
	hits += instance_place_list(x, y, oBoss1, hitByAttackNow, false);
	if (hits > 0)
	{
		for (var i = 0; i < hits; i++)
		{
			var hitID = hitByAttackNow[| i];
			if (ds_list_find_index(hitByAttack, hitID) == -1)
			{
				ds_list_add(hitByAttack, hitID);
				with (hitID)
				{
					hp -= 2;
					flash = 3;
					hitfrom = other.attack_dir;
				}
			}
		}
	}
	ds_list_destroy(hitByAttackNow);
	
	if (animation_end())
	{
		mask_index = -1;
		combo_count = 0;
		state = PLAYERSTATE.FREE;
	}
	else
		mask_index = sPlayerA2HB;
}
