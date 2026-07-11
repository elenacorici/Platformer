// ── Iela1 nu moare niciodata din damage (hp clampat de controller la >=1).
// Cand AMBELE surori au murit (iele2_dead && iele3_dead), ea e ultima ramasa —
// face o plecaciune de ramas bun (Part 1), apoi fuge definitiv spre dreapta
// (Part 2, loop) → la iesirea din ecran seteaza fight_ended (win condition).
// Blocheaza orice alta logica (controller-ul deja nu mai porneste nimic nou
// odata ce iele2_dead && iele3_dead, vezi oBoss3Controller/Step_0.gml).
if (instance_exists(oBoss3Controller)
&&  oBoss3Controller.iele2_dead && oBoss3Controller.iele3_dead)
{
    if (escape_phase == 0)
    {
        escape_phase      = 1;
        escape_holding    = false;
        hsp               = 0;
        vsp               = 0;
        sprite_index      = spr_bow;
        image_index       = 0;
        image_speed       = 0.15;
        var _px = instance_exists(oPlayer) ? oPlayer.x : x;
        image_xscale = (_px >= x) ? -image_xscale_base : image_xscale_base; // se intoarce spre player
    }
    else if (escape_phase == 1)
    {
        // Faza 1a: joaca animatia de plecaciune pana la capat, apoi
        // INGHEATA pe ultimul cadru (escape_holding) un timp fix — altfel
        // animation_end() ar trece direct la faza de fuga in acelasi frame
        // in care s-a terminat plecaciunea, facand-o practic invizibila.
        if (!escape_holding)
        {
            if (animation_end())
            {
                escape_holding    = true;
                escape_hold_timer = 40; // ~0.67 sec pauza vizibila pe ultimul cadru
                image_index        = sprite_get_number(spr_bow) - 1;
                image_speed         = 0;
            }
        }
        else
        {
            escape_hold_timer--;
            if (escape_hold_timer <= 0)
            {
                escape_phase   = 2;
                escape_holding = false;
                sprite_index   = spr_flee;
                image_index    = 0;
                image_speed    = 0.25;
                // FIX: implicit (nemirror) = orientata spre STANGA (convenite
                // in tot restul codului) — ca sa alerge cu fata spre dreapta
                // (directia reala de fuga, hsp pozitiv mai jos) trebuie
                // oglindita, deci semn NEGATIV. Inainte era pozitiv, facand-o
                // sa alerge cu spatele.
                image_xscale = -image_xscale_base;
            }
        }
    }
    else // escape_phase == 2 — sprint spre dreapta, loop pana iese din ecran
    {
        hsp = 6;
        x  += hsp;

        vsp += grv;
        if (place_meeting(x, y + vsp, oWall)) { while (!place_meeting(x, y + 1, oWall)) y++; vsp = 0; }
        else y += vsp;

        if (x > room_width + 150)
        {
            oBoss3Controller.fight_ended = true;
            instance_destroy();
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
