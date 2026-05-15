/// @func EnemyState_Patrol()
function EnemyState_Patrol()
{
    hsp = patrol_move_speed * patrol_dir;
    if (idle_break_phase != 0)
        hsp = 0;

    _Enemy_HorizontalResolve();
    Enemy_VerticalResolve();
    _Enemy_UpdateLocomotionAnim();
}

/// @func EnemyState_Chase(ctx)
function EnemyState_Chase(_ctx)
{
    if (_ctx.dist > attack_range)
        hsp = move_speed * _ctx.chase_dir;
    else
        hsp = 0;

    if (idle_break_phase != 0)
        hsp = 0;

    _Enemy_HorizontalResolve();
    Enemy_VerticalResolve();
    _Enemy_UpdateLocomotionAnim();
}

/// @func EnemyState_Attack()
function EnemyState_Attack()
{
    hsp = 0;

    _Enemy_HorizontalResolve();
    Enemy_VerticalResolve();

    if (Enemy_IsWolfEnemy())
        sprite_index = sWolfA;
    else
        sprite_index = sEnemyA;
    image_speed = attack_anim_speed;

    // Hitbox
    var _old_mask = mask_index;
    if (Enemy_IsWolfEnemy())
        mask_index = sWolfAHB;
    else
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

    if (animation_end())
    {
        state = state_after_attack;
        image_index = 0;
        attack_cooldown = attack_cooldown_frames;
    }
}

// ── FUNCȚII INTERNE (prefixate cu _ ca să fie clare) ──────────────────────────

function _Enemy_HorizontalResolve()
{
    var _edge_dir = (sign(hsp) != 0) ? sign(hsp) : patrol_dir;
    if (idle_break_phase == 0 && grounded && afraidOfHeights && !place_meeting(x + check_distance * _edge_dir, y + 1, oWall))
    {
        hsp = -hsp;
        patrol_dir = -patrol_dir;
    }

    if (place_meeting(x + hsp, y, oWall))
    {
        while (!place_meeting(x + sign(hsp), y, oWall))
            x += sign(hsp);
        hsp = -hsp;
        patrol_dir = -patrol_dir;
    }
    x += hsp;
}


function _Enemy_UpdateLocomotionAnim()
{
    if (Enemy_IsWolfEnemy())
    {
        if (!place_meeting(x, y + 1, oWall))
        {
            if (idle_break_phase != 0) { idle_break_phase = 0; idle_break_breath_timer = 0; }
            grounded = false;
            image_speed = 0.25;
            sprite_index = sWolfR;
        }
        else if (idle_break_phase == 1)
        {
            grounded = true;
            sprite_index = sWolf;
            var _m = (state == ENEMYSTATE.PATROL) ? idle_patrol_idle_anim_mult : 1;
            image_speed = idle_breath_image_speed * _m;
        }
        else if (idle_break_phase == 2)
        {
            grounded = true;
            sprite_index = sWolf;
            var _m2 = (state == ENEMYSTATE.PATROL) ? idle_patrol_idle_anim_mult : 1;
            image_speed = idle_scratch_image_speed * _m2;
        }
        else
        {
            grounded = true;
            image_speed = 0.25;
            sprite_index = (sign(hsp) == 0) ? sWolf : sWolfR;
        }

        if (idle_break_phase == 2 && sprite_index == sWolf && animation_end())
        {
            idle_break_phase = 0;
            idle_break_cooldown = irandom_range(idle_break_cooldown_min, idle_break_cooldown_max);
            image_index = 0;
        }
        return;
    }

    // oEnemy clasic
    if (!place_meeting(x, y + 1, oWall))
    {
        if (idle_break_phase != 0) { idle_break_phase = 0; idle_break_breath_timer = 0; }
        grounded = false;
        image_speed = 0.4;
        sprite_index = sEnemyJ;
    }
    else if (idle_break_phase == 1)
    {
        grounded = true;
        sprite_index = sEnemy;
        var _m = (state == ENEMYSTATE.PATROL) ? idle_patrol_idle_anim_mult : 1;
        image_speed = idle_breath_image_speed * _m;
    }
    else if (idle_break_phase == 2)
    {
        grounded = true;
        sprite_index = sEnemyI;
        var _m2 = (state == ENEMYSTATE.PATROL) ? idle_patrol_idle_anim_mult : 1;
        image_speed = idle_scratch_image_speed * _m2;
    }
    else
    {
        grounded = true;
        image_speed = 0.4;
        sprite_index = (sign(hsp) == 0) ? sEnemy : sEnemyR;
    }

    if (idle_break_phase == 2 && sprite_index == sEnemyI && animation_end())
    {
        idle_break_phase = 0;
        idle_break_cooldown = irandom_range(idle_break_cooldown_min, idle_break_cooldown_max);
        image_index = 0;
    }
}
