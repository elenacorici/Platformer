vsp += grv;

// ── Comportament legat de un oBranch (setat din Creation Code cu linked_branch) ──
if (variable_instance_exists(id, "linked_branch") && instance_exists(linked_branch))
{
    var _branch_idle = (linked_branch.state == "idle");
    patrol_dist = _branch_idle ? linked_branch_dist : 0;

    // La momentul ridicarii branch-ului, porneste spre stanga (spre player)
    if (!_branch_idle && linked_branch_was_idle)
        patrol_dir = -1;

    linked_branch_was_idle = _branch_idle;
}

// ── Context player ────────────────────────────────────────────────────────────
var _same_level_max = (wall_tile_height * 0.5) + same_level_slack;
var _can_see_player = false;
var _chase_dir = 1;
var _dist = 999999;
var _floor_toward_player = false;

if (instance_exists(oPlayer))
{
    _dist = point_distance(x, y, oPlayer.x, oPlayer.y);
    _chase_dir = sign(oPlayer.x - x);
    if (_chase_dir == 0) _chase_dir = 1;
    _floor_toward_player = place_meeting(x + _chase_dir * check_distance, y + 1, oWall);
    var _check_y = y;
    if (Enemy_IsWolfEnemy() && mask_index != -1)
        _check_y += (sprite_get_bbox_bottom(mask_index) - sprite_get_yoffset(mask_index)) * size;
    _can_see_player = (_dist < sight_range && abs(_check_y - oPlayer.y) < _same_level_max && grounded);
}

var ctx = {
    same_level_max: _same_level_max,
    can_see_player: _can_see_player,
    chase_dir: _chase_dir,
    dist: _dist,
    floor_toward_player: _floor_toward_player
};

// ── Wolf: sleep mechanic ──────────────────────────────────────────────────────
if (Enemy_IsWolfEnemy())
{
    if (_can_see_player || state != ENEMYSTATE.PATROL)
        player_absent_timer = 0;
    else
        player_absent_timer++;

    // Trezire cand playerul intra in raza
    if (sleep_phase > 0 && _can_see_player)
    {
        sleep_phase = 0;
        player_absent_timer = 0;
    }

    // Intrare in sleep dupa absenta lunga a playerului
    if (sleep_phase == 0 && state == ENEMYSTATE.PATROL
    &&  idle_break_phase == 0 && player_absent_timer >= 400)
    {
        sleep_phase = 1;
        image_index = 0;
    }

    // Trezire periodica: dupa ~10 secunde de somn pleaca la ture, apoi readoarme
    if (sleep_phase == 2)
    {
        sleep_wander_timer++;
        if (sleep_wander_timer >= 600)
        {
            sleep_phase = 0;
            sleep_wander_timer = 0;
            player_absent_timer = 0;
        }
    }
    else
        sleep_wander_timer = 0;
}

// ── Cooldown-uri ──────────────────────────────────────────────────────────────
if (attack_cooldown > 0) attack_cooldown--;
if (idle_break_phase == 0 && idle_break_cooldown > 0) idle_break_cooldown--;

// ── Idle break (pauze la margine platformă) ───────────────────────────────────
var _idle_ledge_dir  = (state == ENEMYSTATE.CHASE) ? ctx.chase_dir : patrol_dir;
var _idle_skip_near  = (state == ENEMYSTATE.CHASE && ctx.dist <= attack_range);
var _idle_edge_px    = check_distance + idle_edge_extra;
var _at_edge         = grounded && !place_meeting(x + _idle_edge_px * _idle_ledge_dir, y + 1, oWall);

if (idle_break_phase == 1)
{
    idle_break_breath_timer--;
    if (idle_break_breath_timer <= 0)
    {
        if (idle_break_will_scratch)
        {
            idle_break_phase = 2;
            image_index = 0;
        }
        else
        {
            idle_break_phase = 0;
            idle_break_cooldown = irandom_range(idle_break_cooldown_min, idle_break_cooldown_max);
        }
    }
}

if (idle_break_phase == 0 && idle_break_cooldown <= 0 && grounded
    && attack_cooldown <= 0
    && (state == ENEMYSTATE.PATROL || state == ENEMYSTATE.CHASE)
    && _at_edge && !_idle_skip_near && random(1) < idle_break_roll_chance_ledge)
{
    idle_break_phase = 1;
    idle_break_breath_timer = irandom_range(idle_breath_min_frames, idle_breath_max_frames);
    idle_break_will_scratch = (random(1) < idle_scratch_chance);
}

// ── Tranziții de stare ────────────────────────────────────────────────────────
if (state == ENEMYSTATE.CHASE)
{
    if (!instance_exists(oPlayer) || ctx.dist > sight_range
        || abs(y - oPlayer.y) >= ctx.same_level_max || !ctx.floor_toward_player)
        state = ENEMYSTATE.PATROL;
}

if (state == ENEMYSTATE.PATROL && ctx.can_see_player && ctx.floor_toward_player)
    state = ENEMYSTATE.CHASE;

var _attack_check_y = y;
if (Enemy_IsWolfEnemy() && mask_index != -1)
    _attack_check_y += (sprite_get_bbox_bottom(mask_index) - sprite_get_yoffset(mask_index)) * size;
if (state == ENEMYSTATE.CHASE && instance_exists(oPlayer) && grounded
    && attack_cooldown <= 0 && ctx.dist <= attack_range
    && ctx.floor_toward_player && abs(_attack_check_y - oPlayer.y) < ctx.same_level_max)
{
    if (idle_break_phase != 0) { idle_break_phase = 0; idle_break_breath_timer = 0; }
    if (Enemy_IsWolfEnemy())
    {
        wolf_jump_active    = false;
        idle_break_cooldown = idle_break_cooldown_max;
    }
    state_after_attack = ENEMYSTATE.CHASE;
    state = ENEMYSTATE.ATTACK;
    image_index = 0;
    ds_list_clear(hitPlayerThisAttack);
}

// ── Execuție stare ────────────────────────────────────────────────────────────
if (Enemy_IsWolfEnemy() && sleep_phase > 0)
{
    hsp = 0;
    Enemy_VerticalResolve();
    _Enemy_UpdateLocomotionAnim();
}
else
{
    switch (state)
    {
        case ENEMYSTATE.PATROL: EnemyState_Patrol();      break;
        case ENEMYSTATE.CHASE:  EnemyState_Chase(ctx);    break;
        case ENEMYSTATE.ATTACK: EnemyState_Attack();      break;
    }
}

// ── Facing ────────────────────────────────────────────────────────────────────
var _face_player = (state == ENEMYSTATE.CHASE) || (state == ENEMYSTATE.ATTACK) || ctx.can_see_player;
if (_face_player && instance_exists(oPlayer))
{
    var _fx = sign(oPlayer.x - x);
    if (_fx == 0) _fx = 1;
    image_xscale = -_fx * size;
}
else if (sign(hsp) != 0)
    image_xscale = -sign(hsp) * size;
else
    image_xscale = -patrol_dir * size;
image_yscale = size;
