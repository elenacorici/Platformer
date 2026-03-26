/// @description Același state machine ca oEnemy (PATROL / CHASE / ATTACK), sprite-uri lup în scripturi.
vsp += grv;

var ctx = Enemy_GetPlayerContext();
Enemy_Step_Cooldowns();

var _idle_ledge_dir = (state == ENEMYSTATE.CHASE) ? ctx.chase_dir : patrol_dir;
var _idle_skip_near = (state == ENEMYSTATE.CHASE && ctx.dist <= attack_range);
Enemy_Idle_Update(ctx, _idle_ledge_dir, _idle_skip_near);

if (state == ENEMYSTATE.CHASE)
{
	if (!instance_exists(oPlayer) || ctx.dist > sight_range || abs(y - oPlayer.y) >= ctx.same_level_max || !ctx.floor_toward_player)
		state = ENEMYSTATE.PATROL;
}

if (state == ENEMYSTATE.PATROL && ctx.can_see_player && ctx.floor_toward_player)
	state = ENEMYSTATE.CHASE;

if (state == ENEMYSTATE.CHASE && instance_exists(oPlayer) && grounded && attack_cooldown <= 0
	&& ctx.dist <= attack_range && ctx.floor_toward_player && abs(y - oPlayer.y) < ctx.same_level_max)
{
	if (idle_break_phase != 0)
	{
		idle_break_phase = 0;
		idle_break_breath_timer = 0;
	}
	state_after_attack = ENEMYSTATE.CHASE;
	state = ENEMYSTATE.ATTACK;
	image_index = 0;
	ds_list_clear(hitPlayerThisAttack);
}

switch (state)
{
	case ENEMYSTATE.PATROL:
		EnemyState_Patrol();
		break;
	
	case ENEMYSTATE.CHASE:
		EnemyState_Chase(ctx);
		break;
	
	case ENEMYSTATE.ATTACK:
		EnemyState_Attack();
		break;
}

Enemy_UpdateFacing(ctx);
