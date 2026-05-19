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
            // Mers înapoi animat
            sprite_index = sPlayerR;
            image_speed  = 0.13;
            x += sign(_diff) * min(abs(_diff), 2); // max 2px/frame = pași lenți
            image_xscale = (fm_dir > 0) ? 1 : -1;  // față spre boss în timp ce merge înapoi
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
        var _dy = [ 0,  0, -2, -5, -7, -5, -2,  0,   0,  0]; // arc parabolic

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

                    // 2. Snap player la nivelul pieptului boss-ului
                    // boss.y = tălpi (bottom-center), chest = boss.y - (77-30)*2.5
                    x = fm_boss.x;
                    y = fm_boss.y - 117; // pieptul Strigoiului față de tălpi
                }
            }
            else
            {
                x += _dx[_fi] * fm_dir;
                y += _dy[_fi];
            }
        }

        // Freeze pe frame 9/10 — după ce animația s-a terminat
        if (animation_end())
        {
            fm_phase      = 3;
            image_speed   = 0;
            fm_prev_frame = 150;
            // Coboară player la originea boss-ului + offset vizual
            // Origin player (stake y=48 × 1.25) = origin boss (piept y=30 × 2.2)
            if (instance_exists(fm_boss))
                y = fm_boss.y - 117;
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
            fm_phase = 4;
            hsp      = -fm_dir * 2;
            vsp      = -2;
        }
    }

    // ── FAZA 4 — zbor departe de strigoi ─────────────────────
    else if (fm_phase == 4)
    {
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
