// grv = 0, deci nu se aplica gravitatie

// ── Moarte ────────────────────────────────────────────────────────────────
if (dying || hp <= 0)
{
    if (!dying)
    {
        dying       = true;
        image_index = 0;
    }
    sprite_index = sGhostDie;
    image_speed  = 0.2;
    image_yscale = size;
    y           -= 0.4;
    if (animation_end())
        instance_destroy();
    exit;
}

var _dist  = 999999;
var _dir_x = patrol_dir;
var _angle = 0;

if (instance_exists(oPlayer))
{
    _dist  = point_distance(x, y, oPlayer.x, oPlayer.y);
    _dir_x = sign(oPlayer.x - x);
    _angle = point_direction(x, y, oPlayer.x, oPlayer.y);
}

// ── Cooldown atac ─────────────────────────────────────────────────────────
if (attack_cooldown > 0) attack_cooldown--;

// ── Post-atac: idle + ridicare usoara, inainte sa reia chase-ul ───────────
if (post_attack_timer > 0)
{
    post_attack_timer--;
    x += post_attack_drift * 0.7;
    y += (float_y_base - 22 - y) * 0.06;
    sprite_index = sGhostIdle;
    image_speed  = 0.15;
    if (instance_exists(oPlayer))
        image_xscale = -sign(oPlayer.x - x) * size;
    image_yscale = size;
    exit;
}

// ── Tranzitii stare ───────────────────────────────────────────────────────
if (state == ENEMYSTATE.PATROL && instance_exists(oPlayer) && _dist < sight_range)
    state = ENEMYSTATE.CHASE;

if (state == ENEMYSTATE.CHASE)
{
    if (!instance_exists(oPlayer) || _dist > sight_range * 1.5)
        state = ENEMYSTATE.PATROL;
    else if (attack_cooldown <= 0 && _dist < attack_range)
    {
        state = ENEMYSTATE.ATTACK;
        image_index = 0;
        ds_list_clear(hitPlayerThisAttack);
    }
}

// ── Executie stare ────────────────────────────────────────────────────────
switch (state)
{
    case ENEMYSTATE.PATROL:
        float_time++;
        var _ty_float = float_y_base + sin(float_time * 0.035) * float_amplitude;
        y += (_ty_float - y) * 0.1;

        hsp = patrol_dir * patrol_move_speed;
        if (abs(x - xstart) >= patrol_range_x)
        {
            patrol_dir = -patrol_dir;
            hsp        = patrol_dir * patrol_move_speed;
        }
        x += hsp;

        sprite_index = sGhostIdle;
        image_speed  = 0.15;
        break;

    case ENEMYSTATE.CHASE:
        if (instance_exists(oPlayer))
        {
            var _dx  = oPlayer.x - x;
            var _dy  = oPlayer.y - y;
            var _len = sqrt(_dx * _dx + _dy * _dy);
            if (_len > 0.5)
            {
                hsp = (_dx / _len) * move_speed;
                x  += hsp;
                y  += (_dy / _len) * move_speed;
            }
        }

        sprite_index = sGhostIdleChase;
        image_speed  = 0.15;
        break;

    case ENEMYSTATE.ATTACK:
        sprite_index = sGhostIdleAttack_front;
        image_speed  = 0.35;

        // Hitbox via sprite dedicat
        var _old_mask = mask_index;
        mask_index = sGhostIdleAttack_HB;
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
                    hp       = max(0, hp);
                    flash    = 3;
                    hitfrom  = point_direction(other.x, other.y, x, y);
                }
            }
        }
        ds_list_destroy(_plist);
        mask_index = _old_mask;

        if (animation_end())
        {
            state             = ENEMYSTATE.CHASE;
            image_index       = 0;
            attack_cooldown   = attack_cooldown_frames;
            post_attack_timer = attack_cooldown_frames;
            post_attack_drift = choose(-1, 1) * random_range(0.4, 0.9);
            ds_list_clear(hitPlayerThisAttack);
        }
        break;
}

// ── Facing ────────────────────────────────────────────────────────────────
if (instance_exists(oPlayer))
    image_xscale = -sign(oPlayer.x - x) * size;
else
    image_xscale = -patrol_dir * size;
image_yscale = size;
