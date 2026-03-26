/// @func EnemyState_Attack()
/// @desc Animație atac + hitbox; sprite-uri după tip (oEnemy vs lup).
function EnemyState_Attack()
{
	hsp = 0;
	
	Enemy_HorizontalResolve();
	Enemy_VerticalResolve();
	
	if (Enemy_IsWolfEnemy())
		sprite_index = sWolfA;
	else
		sprite_index = sEnemyA;
	image_speed = attack_anim_speed;
	
	Enemy_AttackHitbox();
	
	if (animation_end())
	{
		state = state_after_attack;
		image_index = 0;
		attack_cooldown = attack_cooldown_frames;
	}
}
