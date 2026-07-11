/// @func IeleIntro()
/// Fizica + animatie Iela in intro (inainte de fight_started).
function IeleIntro()
{
    var _ctrl = instance_exists(oBoss3Controller);
    var _ax1  = _ctrl ? oBoss3Controller.arena_x1 : 80;
    var _ax2  = _ctrl ? oBoss3Controller.arena_x2 : (room_width - 80);
    var _cx   = (_ax1 + _ax2) * 0.5;

    // Gravitatie + coliziune verticala
    vsp += grv;
    if (place_meeting(x, y + vsp, oWall))
    {
        while (!place_meeting(x, y + 1, oWall)) y++;
        vsp = 0;
    }
    else y += vsp;

    // Pre-trigger: sta nemiscata
    if (!_ctrl || !oBoss3Controller.intro_triggered)
    {
        sprite_index = spr_static;
        image_speed  = 0;
        image_index  = 0;
        return;
    }

    // ── Seteaza hsp in functie de faza ────────────────────────
    switch (intro_walk_phase)
    {
        case "patrol":
            if (intro_bounces >= 3)
            {
                intro_walk_phase = "walk";
                hsp = 0;
            }
            else
                hsp = intro_pat_dir * 2.5;
            break;

        case "walk":
        {
            var _target = _cx + intro_center_offset;
            var _dx     = _target - x;
            if (abs(_dx) < 80)
            {
                hsp = 0;
                intro_walk_phase = "wait";
            }
            else
                hsp = sign(_dx) * 1.5;
            break;
        }

        case "wait":
            hsp = 0;
            break;
    }

    // Hop periodic la alergare
    if (!variable_instance_exists(id, "intro_hop_timer"))
        intro_hop_timer = irandom_range(5, 30);
    intro_hop_timer--;
    if (intro_hop_timer <= 0 && vsp == 0
    &&  place_meeting(x, y + 1, oWall) && abs(hsp) > 1.8)
    {
        vsp             = -1.5;
        intro_hop_timer = 28 + irandom(14);
    }

    // ── Coliziune orizontala + detectie bounce ─────────────────
    // "patrol" ARE NEVOIE de coliziune reala (se loveste intentionat de 3 ori
    // ca sa stie unde sunt marginile arenei, inainte sa treaca la "walk").
    // "walk" (spre centrul arenei) are deja propria oprire pe distanta
    // (abs(_dx)<80 mai sus) — nu trebuie sa se blocheze fizic in zid daca,
    // dupa redimensionarea room-ului sau alte variatii, tinta ei ajunge sa
    // fie dincolo de un perete pe care patrol-ul nu l-a extras-o complet.
    if (intro_walk_phase == "walk")
    {
        x += hsp;
    }
    else if (hsp != 0 && place_meeting(x + hsp, y, oWall))
    {
        // Muta la marginea peretelui
        while (!place_meeting(x + sign(hsp), y, oWall)) x += sign(hsp);

        // Bounce: se numara o singura data per atingere
        if (intro_walk_phase == "patrol" && !intro_at_wall)
        {
            intro_at_wall = true;
            intro_pat_dir = -intro_pat_dir;
            intro_bounces++;
            if (intro_bounces >= 3)
            {
                intro_walk_phase = "walk";
                hsp = 0;
                // intro_pat_dir e acum spre centru; scoate iela din zona peretelui
                // altfel place_meeting(x + hsp, y, oWall) ramane true si walk-ul se blocheaza
                while (place_meeting(x + intro_pat_dir * 2, y, oWall))
                    x += intro_pat_dir;
            }
            else
                hsp = intro_pat_dir * 2.5; // porneste imediat in noua directie
        }
        else
            hsp = 0;
    }
    else
    {
        x += hsp;
        // Departe de perete → poate conta urmatoarea atingere
        if (intro_walk_phase == "patrol") intro_at_wall = false;
    }

    // Facing
    if (abs(hsp) > 0.1)
    {
        facing       = sign(hsp);
        image_xscale = -facing * image_xscale_base;
    }

    // Animatie
    if (intro_walk_phase == "wait")
    {
        sprite_index = spr_idle_still;
        image_speed  = 0.1;
    }
    else if (abs(hsp) > 1.8)
    {
        if (sprite_index != spr_skip) { sprite_index = spr_skip; image_speed = 0.2; }
    }
    else if (abs(hsp) > 0.2)
    {
        if (sprite_index != spr_walk) { sprite_index = spr_walk; image_speed = 0.13; }
    }
    else
    {
        sprite_index = spr_static;
        image_speed  = 0;
        image_index  = 0;
    }
}
