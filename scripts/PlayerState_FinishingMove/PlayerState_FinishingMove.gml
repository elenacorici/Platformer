/// @func PlayerState_FinishingMove()
function PlayerState_FinishingMove()
{
    // Faza 4 = zbor liber — nu resetăm viteza
    if (fm_phase != 4)
    {
        hsp = 0;
        vsp = 0;
    }

    // ── FAZA 0 — merge înapoi cu pași până la distanța corectă ──
    if (fm_phase == 0)
    {
        var _diff = fm_target_x - x;

        if (abs(_diff) > 3) // nu a ajuns încă
        {
            // Mers înapoi animat — reseteaza sprite la prima intrare
            if (sprite_index != sPlayerR) {
                sprite_index = sPlayerR;
                image_index  = 0;
            }
            image_speed  = 1;
            x += sign(_diff) * min(abs(_diff), 3); // max 3px/frame
            image_xscale = (sign(_diff) > 0) ? -1 : 1; // fata spre directia de mers
        }
        else
        {
            // A ajuns la distanța corectă → P1
            x            = fm_target_x;
            fm_phase     = 1;
            sprite_index = sPlayerStakeP1;
            image_index  = 0;
            image_speed  = 0.2;
            fm_prev_frame = 0;
            image_xscale = (fm_dir > 0) ? 1 : -1;
            // Ridica playerul ca picioarele sa fie la sol (origin pe stake, nu pe picioare)
            // Picioare sPlayerStakeP1 la sprite y=57, origin la y=39 → offset (57-39)*1.25 = 22.5
            y -= (57 - 39) * image_yscale;
        }
    }

    // ── FAZA 1 — pregătire pe loc ────────────────────────────────
    else if (fm_phase == 1)
    {
        if (animation_end())
        {
            fm_phase      = 2;
            sprite_index  = sPlayerStakeP2;
            image_index   = 0;
            image_speed   = 0.2;
            fm_prev_frame = 0;
        }
    }

    // ── FAZA 2 — săritură + impact ───────────────────────────────
    else if (fm_phase == 2)
    {
        var _fi = floor(image_index);
        var _fp = floor(fm_prev_frame);

        var _dx = [ 0,  5, 15, 30, 38, 35, 27,  0,  -5, -2];
        var _dy = [ 0,  0, -8, -18, -20, -15, -10,  0,   0,  0]; // arc parabolic ridicat

        if (_fi != _fp && _fi >= 0 && _fi < 10)
        {
            if (_fi == 7) // Frame 8 — mai întâi ajustează boss, apoi snap player
            {
                if (instance_exists(fm_boss))
                {
                    // 1. Schimbă boss la dying (bottom-center — fără y offset)
                    with (fm_boss)
                    {
                        hp           = 0;
                        state        = "dying";
                        sprite_index = sBoss2Die;
                        image_index  = 2;
                        image_speed  = 0;
                        image_angle  = 0;
                        hsp          = 0;
                    }

                    // 2. Snap player: aliniaza originea playerului cu tarusul din strigoi (47,29)
                    x = fm_boss.x + (47 - 44) * fm_dir * 2.5; // = boss.x + 7.5 * fm_dir
                    y = fm_boss.y + (29 - 71) * 2.5;          // = boss.y - 105
                }
            }
            else
            {
                x += _dx[_fi] * fm_dir;
                y += _dy[_fi];
            }
        }

        // Freeze la frame 10 (0-indexed)
        if (floor(image_index) >= 10)
        {
            fm_phase      = 3;
            image_speed   = 0;
            image_index   = 10;
            fm_prev_frame = 150;
            if (instance_exists(fm_boss))
                y = fm_boss.y - 89;
        }
    }

    // ── FAZA 3 — freeze: ambii agatati pe frame ──────────────────
    else if (fm_phase == 3)
    {
        fm_prev_frame--;

        if (fm_prev_frame <= 0)
        {
            // Eliberează boss — continuă animația de moarte
            if (instance_exists(fm_boss))
                fm_boss.image_speed = 0.1;

            // Faza de zbor — player sare departe de strigoi
            fm_phase    = 4;
            hsp         = -fm_dir * 2;
            vsp         = -2;
            image_speed = 0.3; // continua ultimele frame-uri in timp ce cade
        }
    }

    // ── FAZA 4 — zbor departe de strigoi ─────────────────────
    else if (fm_phase == 4)
    {
        // Opreste animatia dupa ultimul frame
        if (image_speed > 0 && animation_end())
            image_speed = 0;

        vsp += grv;
        x   += hsp;
        y   += vsp;

        // Aterizare → control redat
        if (place_meeting(x, y + 1, oWall))
        {
            vsp        = 0;
            state      = PLAYERSTATE.FREE;
            hascontrol = true;
            hsp        = 0;
            fm_phase   = -1;
            fm_boss    = noone;
            depth      = 0;

            if (instance_exists(oCamera))
                oCamera.follow = oPlayer;
        }
    }

    fm_prev_frame = (fm_phase == 3) ? fm_prev_frame : image_index;
}
