/// @func Enemy_AttackHitbox()
function Enemy_AttackHitbox()
{
	if (state != ENEMYSTATE.ATTACK)
		return;
	
	var _old_mask = mask_index;
	mask_index = sEnemyAHitBox;
	var _plist = ds_list_create();
	var _nhits = instance_place_list(x, y, oPlayer, _plist, false);
	for (var _hi = 0; _hi < _nhits; _hi++)
	{
		var _pid = _plist[| _hi];
		if (ds_list_find_index(hitPlayerThisAttack, _pid) == -1)
		{
			ds_list_add(hitPlayerThisAttack, _pid);
			with (_pid)
			{
				hp--;
				hp = max(0, hp);
				flash = 3;
				hitfrom = point_direction(other.x, other.y, x, y);
			}
		}
	}
	ds_list_destroy(_plist);
	mask_index = _old_mask;
}
