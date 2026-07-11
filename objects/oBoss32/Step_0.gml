// ── Moarte (3 parti: hop-uri esuate → ridicare → destrama) ──────
if (is_dead)
{
    hsp = 0;

    if (death_phase == 0)
    {
        death_phase     = 1;
        death_hop_count = 0;
        sprite_index    = spr_die_a; // incearca sa zboare, nu reuseste
        image_index     = 0;
        image_speed     = 0.12;
        vsp             = -2.2; // primul hop
    }

    if (death_phase == 1)
    {
        // Hop-uri mici, repetate — cade, aterizeaza, mai incearca o data.
        vsp += grv;
        if (place_meeting(x, y + vsp, oWall))
        {
            while (!place_meeting(x, y + 1, oWall)) y++;
            vsp = 0;
            death_hop_count++;

            if (death_hop_count < 3)
            {
                // Inca o incercare esuata
                vsp          = -2.2;
                image_index  = 0;
                image_speed  = 0.12;
            }
            else
            {
                // Ultima incercare — de data asta se ridica cu adevarat putin,
                // iar destramarea (B) porneste IN AER, nu pe sol.
                death_phase  = 2;
                death_lift_t = 0;
                vsp          = -4.5;
            }
        }
        else y += vsp;
    }
    else if (death_phase == 2)
    {
        // Ridicare scurta (gravitate redusa temporar) inainte de faza B.
        death_lift_t++;
        vsp += grv * 0.3;
        y   += vsp;

        if (death_lift_t >= 26)
        {
            death_phase  = 3;
            sprite_index = spr_die_b; // destrama
            image_index  = 0;
            image_speed  = 0.08; // incet, ca sa se vada clar animatia
        }
    }
    else if (death_phase == 3)
    {
        vsp += grv * 0.3; // continua sa pluteasca usor cat se destrama
        y   += vsp;

        if (animation_end())
        {
            image_speed = 0;
            visible     = false; // s-a destramat complet
            death_phase = 4;
        }
    }

    exit;
}

// ── Intro (inainte de inceperea luptei) — nu leviteaza, nu urmareste player ──
if (instance_exists(oBoss3Controller) && !oBoss3Controller.fight_started)
{
    IeleIntro();
    exit;
}

IeleUpdate();
