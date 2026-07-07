/// @func IelePerch()
/// Apelat din IeleUpdate cand iele_attack = "perch"
/// Iela zboara spre pozitia de creanga si se aseaza
function IelePerch()
{
    // ── DISMOUNT: saritura dramatica de pe creanga ────────────────
    if (iele_attack == "dismount")
    {
        vsp += grv;

        sprite_index = spr_jump;
        image_speed  = 0.15;
        hsp          = 0;
        image_yscale = image_yscale_base;

        // Priveste spre player in timp ce cade
        var _px = instance_exists(oPlayer) ? oPlayer.x : x;
        image_xscale = (_px >= x) ? -image_xscale_base : image_xscale_base;

        if (place_meeting(x, y + vsp, oWall))
        {
            while (!place_meeting(x, y + sign(vsp), oWall)) y += sign(vsp);
            vsp = 0;
            y   = floor(y);

            // Aterizare dramatica
            if (instance_exists(oCamera)) ScreenShake(5, 12);

            iele_attack      = "none";
            iele_phase       = "orbit";
            iele_state       = "idle";
            orbit_move_timer = irandom_range(60, 120);
        }
        else
        {
            y = floor(y + vsp);
        }
        return;
    }

    var _ctrl = instance_exists(oBoss3Controller);
    var _tx   = _ctrl ? oBoss3Controller.perch_x : x;
    var _ty   = _ctrl ? oBoss3Controller.perch_y : y;

    var _dx   = _tx - x;
    var _dy   = _ty - y;
    var _dist = point_distance(x, y, _tx, _ty);

    image_yscale = image_yscale_base;

    // ── SOSIT: aseaza-te si eventual arunca ──────────────────────
    if (_dist < 14)
    {
        x            = _tx;
        y            = _ty;
        hsp          = 0;
        vsp          = 0;
        image_yscale = image_yscale_base;
        var _px = instance_exists(oPlayer) ? oPlayer.x : x;
        image_xscale = (_px >= x) ? -image_xscale_base : image_xscale_base;

        if (throw_active)
        {
            throw_timer++;

            if (throw_timer < throw_cooldown)
            {
                // Asteapta intre aruncaturi
                sprite_index = spr_sit;
                image_speed  = 0.12;
            }
            else
            {
                // Animatie de aruncare
                sprite_index = spr_sit_hit;
                image_speed  = 0.25;

                // Spawneaza proiectilul la mijlocul animatiei
                var _mid_frame = sprite_get_number(spr_sit_hit) / 2;
                if (!throw_fired && floor(image_index) >= _mid_frame)
                {
                    throw_fired = true;

                    if (instance_exists(oPlayer))
                    {
                        var _dir = point_direction(x, y, _px, oPlayer.y);
                        var _spd = 4.5;
                        var _p   = instance_create_layer(x, y, "Enemies", oIeleProjectile);
                        _p.proj_spd_x   = lengthdir_x(_spd, _dir);
                        _p.proj_spd_y   = lengthdir_y(_spd, _dir);
                        _p.sprite_index = spr_projectile;
                        _p.image_xscale = 2.8;
                        _p.image_yscale = 1.7;
                    }
                }

                // Dupa animatie: pauza noua random si resetare
                if (animation_end())
                {
                    sprite_index   = spr_sit;
                    image_speed    = 0.12;
                    throw_timer    = 0;
                    throw_fired    = false;
                    throw_cooldown = irandom_range(150, 210);
                }
            }
        }
        else
        {
            sprite_index = spr_sit;
            image_speed  = 0.12;
        }
        return;
    }

    // ── IN ZBOR: dash spre perch ──────────────────────────────────
    var _spd = 5.5;

    facing       = (_dx > 0) ? 1 : -1;
    sprite_index = (spr_dash != -1) ? spr_dash : spr_skip;
    image_speed  = 0.25;

    image_xscale = -facing * image_xscale_base;
    image_yscale = image_yscale_base;

    hsp = facing * _spd;

    // Vertical: zbor direct spre perch_y (fara gravitatie)
    vsp = clamp(_dy * 0.15, -5.5, 5.5);

    // Coliziune orizontala
    if (hsp != 0)
    {
        if (place_meeting(x + hsp, y, oWall))
        {
            while (!place_meeting(x + sign(hsp), y, oWall)) x += sign(hsp);
            hsp = 0;
        }
        else x += hsp;
    }

    y += vsp;
    y  = floor(y);
}
