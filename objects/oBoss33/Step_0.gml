// ── Moarte (2 parti: hop → explozie de lumina) ──────────────────
if (is_dead)
{
    hsp = 0;

    if (death_phase == 0)
    {
        death_phase  = 1;
        sprite_index = spr_jump; // reutilizeaza saltul existent de la "flyover"
        image_speed  = 0.15;
        image_angle  = 0; // altfel, daca moare in timpul zborului spre creanga
                          // (IelePerch.gml), animatia de moarte se deseneaza rotita
        vsp          = -5.5; // acelasi impuls ca la flyover
    }

    if (death_phase == 1)
    {
        // Un singur hop in aer inainte de explozie — la aterizare porneste B.
        vsp += grv;
        if (place_meeting(x, y + vsp, oWall))
        {
            while (!place_meeting(x, y + 1, oWall)) y++;
            vsp = 0;

            death_phase  = 2;
            sprite_index = spr_die;
            image_index  = 0;
            image_speed  = 0.1; // incet, ca sa se vada clar explozia
            image_angle  = 0;
            if (instance_exists(oCamera)) ScreenShake(8, 20);
        }
        else y += vsp;
    }
    else if (death_phase == 2 && animation_end())
    {
        image_speed = 0;
        visible     = false; // disparitie brusca si completa
        death_phase = 3;
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
