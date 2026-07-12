/// @description Patrol hover -> chase -> impunge playerul la contact

// ── MORT — nu mai rulează logica normală ─────────────────
if (state == "dying" || state == "dead")
{
    if (state == "dying")
    {
        // Cade spre podea (albina nu are gravitate normal — doar in moarte)
        vspeed += 0.4;
        y += vspeed;

        if (place_meeting(x, y + 1, oWall))
        {
            vspeed = 0;
            if (animation_end())
            {
                state       = "dead";
                image_index = sprite_get_number(albinuta_death) - 1;
                image_speed = 0;
                dead_timer  = 180; // 3 secunde pe podea
            }
        }
    }
    else // "dead"
    {
        dead_timer--;
        if (dead_timer < 60)
            image_alpha = dead_timer / 60;
        if (dead_timer <= 0)
            instance_destroy();
    }
    exit;
}

var _dist_player = instance_exists(oPlayer) ? point_distance(x, y, oPlayer.x, oPlayer.y) : 99999;

// Linie de vedere — nu "vede" playerul daca exista un oWall intre ei (nu poate
// nici sa intre in chase printr-un zid, nici sa ramana in chase daca un zid
// ajunge intre timp intre ei)
var _los_blocked = instance_exists(oPlayer)
    && collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true) != noone;

if (poke_cooldown > 0) poke_cooldown--;
wobble_timer += wobble_speed;

// ── Tranzitii de stare (histerezis: sight_range < give_up_range) ──────
if (state == "patrol" && _dist_player < sight_range && !_los_blocked)
{
    state = "chase";
}
else if (state == "chase" && (_dist_player > give_up_range || _los_blocked))
{
    state      = "patrol";
    resting    = false;
    rest_timer = 0;

    var _a = random(360);
    var _d = random(patrol_radius);
    hover_target_x = home_x + lengthdir_x(_d, _a);
    hover_target_y = home_y + lengthdir_y(_d, _a);
}

// ── PATROL — hover ambiental intre puncte random, cu pauze scurte ─────
if (state == "patrol")
{
    sprite_index = resting ? albinuta : albinuta_patrol;

    if (resting)
    {
        hspeed = 0;
        vspeed = 0;

        rest_timer--;
        if (rest_timer <= 0)
        {
            resting = false;
            var _a = random(360);
            var _d = random(patrol_radius);
            hover_target_x = home_x + lengthdir_x(_d, _a);
            hover_target_y = home_y + lengthdir_y(_d, _a);
        }
    }
    else
    {
        var _base_dir = point_direction(x, y, hover_target_x, hover_target_y);
        var _wobble   = sin(wobble_timer) * wobble_amp_patrol;
        var _fly_dir  = _base_dir + _wobble;

        hspeed = lengthdir_x(hover_speed, _fly_dir);
        vspeed = lengthdir_y(hover_speed, _fly_dir);

        var _moved_x = true;
        var _moved_y = true;
        if (collision)
        {
            _moved_x = !place_meeting(x + hspeed, y, oWall);
            _moved_y = !place_meeting(x, y + vspeed, oWall);
        }
        if (_moved_x) x += hspeed;
        if (_moved_y) y += vspeed;

        // Ajunsa la tinta SAU blocata complet de un perete (tinta din spatele
        // unui zid ar tine-o vibrand la nesfarsit altfel) — alege alt punct
        if (point_distance(x, y, hover_target_x, hover_target_y) < 8
        || (!_moved_x && !_moved_y))
        {
            resting    = true;
            rest_timer = 0;
        }

        if (hspeed != 0)
            image_xscale = (hspeed < 0) ? -1 : 1;
    }
}

// ── CHASE — homing spre player + impunge la contact ────────────────────
else if (state == "chase")
{
    sprite_index = albinuta_chase;

    if (instance_exists(oPlayer))
    {
        var _target_dir = point_direction(x, y, oPlayer.x, oPlayer.y);
        var _diff        = angle_difference(_target_dir, fly_dir);
        fly_dir         += clamp(_diff, -turn_speed, turn_speed);

        var _wobble     = sin(wobble_timer) * wobble_amp_chase;
        var _dir_final  = fly_dir + _wobble;

        hspeed = lengthdir_x(chase_speed, _dir_final);
        vspeed = lengthdir_y(chase_speed, _dir_final);

        if (!collision || !place_meeting(x + hspeed, y, oWall)) x += hspeed;
        if (!collision || !place_meeting(x, y + vspeed, oWall)) y += vspeed;

        image_xscale = (oPlayer.x < x) ? -1 : 1;

        // Impunge playerul cu fata — contact direct, fara windup/stare separata de atac
        if (poke_cooldown <= 0 && _dist_player < poke_range)
        {
            oPlayer.hp    -= poke_damage;
            oPlayer.hp     = max(0, oPlayer.hp);
            oPlayer.flash  = 3;
            poke_cooldown  = poke_cooldown_max;
        }
    }
}
