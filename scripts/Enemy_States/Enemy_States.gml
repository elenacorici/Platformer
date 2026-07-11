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
    if (Enemy_IsWolfEnemy())
    {
        sprite_index = sWolfA;
        image_speed = attack_anim_speed;

        // Prima frame: initializeaza saltul
        if (!wolf_jump_active)
        {
            wolf_jump_active = true;
            wolf_jump_dir = instance_exists(oPlayer) ? sign(oPlayer.x - x) : patrol_dir;
            if (wolf_jump_dir == 0) wolf_jump_dir = patrol_dir;
            vsp = -5;
            hsp = wolf_jump_dir * 3.5;
        }

        // Miscare orizontala — oprire la margine platforma la coborare
        if (place_meeting(x + hsp, y, oWall))
        {
            while (!place_meeting(x + sign(hsp), y, oWall))
                x += sign(hsp);
            hsp = 0;
        }
        else
        {
            if (vsp > 0 && mask_index != -1)
            {
                // Lookahead de check_distance px cu rectangle mic (fara bug-ul mastii de 176px)
                var _fy = y + (sprite_get_bbox_bottom(mask_index) - sprite_get_yoffset(mask_index)) * size;
                var _lx = x + sign(hsp) * check_distance;
                if (collision_rectangle(_lx - 2, _fy, _lx + 2, _fy + 40, oWall, false, false) == noone)
                    hsp = 0; // nu e sol la check_distance px inainte → opreste
                else
                    x += hsp;
            }
            else
                x += hsp;
        }

        Enemy_VerticalResolve();

        // Hitbox pe durata saltului
        var _old_mask = mask_index;
        mask_index = sWolfAHB;
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

        // Aterizare: vsp >= 0 inseamna ca coboara
        if (vsp >= 0 && place_meeting(x, y + 1, oWall))
        {
            wolf_jump_active = false;
            hsp = 0;
            patrol_dir = wolf_jump_dir;
            state = ENEMYSTATE.PATROL;
            image_index = 0;
            attack_cooldown = attack_cooldown_frames;
            idle_break_cooldown = idle_break_cooldown_max;
        }
        return;
    }

    // oEnemy clasic
    hsp = 0;
    _Enemy_HorizontalResolve();
    Enemy_VerticalResolve();

    sprite_index = sEnemyA;
    image_speed = attack_anim_speed;

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
    var _edge_dir   = (sign(hsp) != 0) ? sign(hsp) : patrol_dir;
    var _has_patrol = variable_instance_exists(id, "patrol_dist") && patrol_dist > 0;

    if (_has_patrol)
    {
        // Auto-init: centreaza intervalul pe pozitia de spawn
        if (!variable_instance_exists(id, "x_patrol_start"))
            x_patrol_start = x - patrol_dist * 0.5;

        // Limita de distanta — inverseaza in PATROL, opreste in CHASE
        var _next_x = x + hsp;
        if (_next_x < x_patrol_start || _next_x > x_patrol_start + patrol_dist)
        {
            if (state == ENEMYSTATE.PATROL)
            {
                hsp = -hsp; patrol_dir = -patrol_dir;
                if (Enemy_IsWolfEnemy()) wolf_just_turned = true;
            }
            else hsp = 0;
        }

        // Edge detection — nu cobora de pe platforma nici in CHASE
        if (idle_break_phase == 0 && place_meeting(x, y + 1, oWall)
        && !place_meeting(x + check_distance * _edge_dir, y + 1, oWall))
        {
            if (state == ENEMYSTATE.PATROL)
            {
                hsp = -hsp; patrol_dir = -patrol_dir;
                if (Enemy_IsWolfEnemy()) wolf_just_turned = true;
            }
            else hsp = 0;
        }
    }
    else
    {
        // Detectie margine platforma — comportament normal
        if (idle_break_phase == 0 && place_meeting(x, y + 1, oWall) && afraidOfHeights
        && !place_meeting(x + check_distance * _edge_dir, y + 1, oWall))
        {
            hsp        = -hsp;
            patrol_dir = -patrol_dir;
        }
    }

    // Coliziune perete — mereu activa
    if (place_meeting(x + hsp, y, oWall))
    {
        while (!place_meeting(x + sign(hsp), y, oWall))
            x += sign(hsp);
        hsp        = -hsp;
        patrol_dir = -patrol_dir;
    }
    x += hsp;
}


function _Enemy_UpdateLocomotionAnim()
{
    if (Enemy_IsWolfEnemy())
    {
        // Sleep override — ruleaza inaintea oricarei alte animatii
        if (sleep_phase > 0)
        {
            grounded = true;
            if (sleep_phase == 1)
            {
                sprite_index = sWolf_sitting;
                image_speed = 0.4;
                if (animation_end()) { sleep_phase = 2; image_index = 0; }
            }
            else // sleep_phase == 2
            {
                sprite_index = sWolf_sleep;
                image_speed = 0.06;
            }
            return;
        }

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
            sprite_index = sWolf_idle;
            image_speed = 0.06;
        }
        else if (idle_break_phase == 2)
        {
            grounded = true;
            sprite_index = sWolf_idle;
            var _m2 = (state == ENEMYSTATE.PATROL) ? idle_patrol_idle_anim_mult : 1;
            image_speed = idle_scratch_image_speed * _m2;
        }
        else
        {
            grounded = true;
            image_speed = 0.25;
            // In CHASE, arata mereu run (gata de salt) chiar daca nu se misca
            sprite_index = (sign(hsp) == 0 && state != ENEMYSTATE.CHASE) ? sWolf_idle : sWolfR;
        }

        if (idle_break_phase == 2 && sprite_index == sWolf_idle && animation_end())
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
