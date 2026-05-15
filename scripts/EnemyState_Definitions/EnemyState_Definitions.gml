/// Stări inamic — același model ca PLAYERSTATE la player.
enum ENEMYSTATE
{
	PATROL,
	CHASE,
	ATTACK
}

/// @func Enemy_IsWolfEnemy()
/// @desc Ramuri sprite/hitbox pentru lup (oEnemyBig / oWolfSmall).
function Enemy_IsWolfEnemy()
{
	return object_index == oEnemyBig || object_index == oWolfSmall;
}

/// @func Enemy_VerticalResolve()
/// @desc Coliziune verticală cu podea/tavan și aplică vsp pe y. Folosit și de boss.
function Enemy_VerticalResolve()
{
	if (place_meeting(x, y + vsp, oWall))
	{
		while (!place_meeting(x, y + sign(vsp), oWall))
			y += sign(vsp);
		vsp = 0;
	}
	y += vsp;
}
