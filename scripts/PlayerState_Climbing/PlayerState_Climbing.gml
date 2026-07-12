function PlayerState_Climbing()
{
    var _key_up   = keyboard_check(vk_up)   || keyboard_check(ord("W"));
    var _key_down = keyboard_check(vk_down)  || keyboard_check(ord("S"));
    var climb_sp  = 2.5;

    hsp = 0;
    vsp = 0;

    // Gaseste obiectul catarabil
    var _climbable = instance_place(x, y, oLadder);
    if (_climbable == noone)
    {
        var _n = instance_number(oBranchBase);
        for (var _i = 0; _i < _n; _i++)
        {
            var _b = instance_find(oBranchBase, _i);
            var _spr    = _b.sprite_index;
            var _half_w = sprite_get_width(_spr) * 0.5 * abs(_b.image_xscale);
            var _top    = _b.y - sprite_get_yoffset(_spr) * abs(_b.image_yscale);
            var _bot    = _b.y + (sprite_get_height(_spr) - sprite_get_yoffset(_spr)) * abs(_b.image_yscale);
            if (abs(x - _b.x) <= _half_w && y >= _top && y <= _bot)
            {
                _climbable = _b;
                break;
            }
        }
    }

    if (_climbable == noone)
    {
        state = PLAYERSTATE.FREE;
        return;
    }

    // Iesire laterala — A/D scoate playerul de pe scara/creanga in orice moment
    var _key_a = keyboard_check(ord("A")) || keyboard_check(vk_left);
    var _key_d = keyboard_check(ord("D")) || keyboard_check(vk_right);
    if (_key_a || _key_d)
    {
        state = PLAYERSTATE.FREE;
        return;
    }

    // Jump off — Space singur = sari sus, Space+A/D = sari lateral
    if (key_jump_pressed)
    {
        var _dir = (keyboard_check(ord("D")) || keyboard_check(vk_right))
                 - (keyboard_check(ord("A")) || keyboard_check(vk_left));
        vsp        = -4.5;
        hsp        = _dir * walksp;
        jumps_left = jumps_max - 1;
        climb_lock = 25;
        if (variable_instance_exists(_climbable, "shake_timer"))
            _climbable.shake_timer = max(_climbable.shake_timer, 35);
        state = PLAYERSTATE.FREE;
        return;
    }

    // Miscare verticala
    if (_key_up)
        vsp = -climb_sp;
    else if (_key_down)
        vsp = climb_sp;

    // Coliziune verticala (podeaua blocheaza)
    if (vsp > 0 && place_meeting(x, y + vsp, oWall))
    {
        while (!place_meeting(x, y + 1, oWall))
            y++;
        vsp = 0;
    }
    else
        y += vsp;

    // Snap x la centrul obiectului catarabil
    x = lerp(x, _climbable.x, 0.3);

    // Leganare continua pe branch
    if (variable_instance_exists(_climbable, "being_climbed"))
        _climbable.being_climbed = true;

    // Animation
    var _spr = (current_weapon == "bow") ? sPlayerBowClimb : sPlayerClimbAxe;
    sprite_index = _spr;
    image_speed  = (vsp != 0) ? 0.15 : 0;
    image_xscale = -1;
}
