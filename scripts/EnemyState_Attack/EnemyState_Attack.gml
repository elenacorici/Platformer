/// @func EnemyState_Attack()
/// @desc Animație atac, hitbox, ieșire la sfârșitul animației.
function EnemyState_Attack()
{
	hsp = 0;
	
	Enemy_HorizontalResolve();
	Enemy_VerticalResolve();
	
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
