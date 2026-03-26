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
