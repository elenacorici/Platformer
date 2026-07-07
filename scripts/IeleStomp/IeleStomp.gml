/// @func IeleStomp()
/// Apelat din IeleUpdate cand iele_attack = "stomp_form" / "stomp_idle"
function IeleStomp()
{
    var _ctrl   = instance_exists(oBoss3Controller);
    var _tx     = _ctrl ? oBoss3Controller.scenario_target_x[my_index] : x;
    var _on_g   = place_meeting(x, y + 1, oWall);
    var _dx     = _tx - x;

    image_yscale = image_yscale_base;

    // ── STOMP_IDLE: aliniata, asteapta delay-ul, apoi tipa ───────
    if (iele_attack == "stomp_idle")
    {
        hsp = 0;
        vsp = 0;

        // Orientare unificata: toate privesc in aceeasi directie,
        // bazat pe pozitia playerului fata de centrul formatiei
        var _px = instance_exists(oPlayer) ? oPlayer.x : x;
        var _fc = _ctrl ? oBoss3Controller.stomp_center_x : x;
        image_xscale = (_px >= _fc) ? -image_xscale_base : image_xscale_base;

        if (!stomp_started)
        {
            sprite_index = spr_idle;
            image_speed  = 0.08;

            // Porneste animatia cand timer-ul sincronizat al controllerului ajunge la start_at
            var _sync_t = _ctrl ? oBoss3Controller.stomp_sync_timer : -1;
            if (_sync_t >= 0 && _sync_t >= stomp_start_at)
            {
                stomp_started     = true;
                stomp_impact_done = false;
                sprite_index      = spr_stomp;
                image_index       = 0;
                image_speed       = 0.05; // incepe foarte lent — dramatic
            }
        }
        else
        {
            sprite_index = spr_stomp;

            // Viteza variabila: anticipare lenta → pre-impact → loop normal
            var _fi = floor(image_index);
            if      (_fi < 3)                   image_speed = 0.05; // anticipare
            else if (_fi < stomp_impact_frame)  image_speed = 0.11; // accelereaza
            else                                image_speed = 0.15; // loop

            // Impact — squash + semnal local
            if (!stomp_impact_done && _fi >= stomp_impact_frame)
            {
                stomp_impact_done = true;
                image_yscale      = image_yscale_base * 0.65; // squash la impact
            }

            // Recovery din squash
            if (stomp_impact_done && image_yscale < image_yscale_base)
                image_yscale = min(image_yscale + 0.06, image_yscale_base);

            // Loop manual: dupa wrap GML, sare inapoi la stomp_loop_frame (nu la 0)
            if (!stomp_looping && _fi >= stomp_loop_frame)
                stomp_looping = true;
            if (stomp_looping && image_index < stomp_loop_frame)
                image_index = stomp_loop_frame;
        }
        return;
    }

    // ── STOMP_FORM: coboara pe sol si merge la pozitie ───────────

    // Gravitatie
    vsp += grv;
    if (place_meeting(x, y + vsp, oWall))
    {
        while (!place_meeting(x, y + sign(vsp), oWall)) y += sign(vsp);
        vsp = 0;
    }
    else y += vsp;
    y = floor(y);

    // Miscare orizontala spre target
    if (abs(_dx) > 12)
    {
        facing       = (_dx > 0) ? 1 : -1;
        sprite_index = (spr_dash != -1) ? spr_dash : spr_skip;
        image_speed  = 0.2;
        image_xscale = -facing * image_xscale_base;
        hsp          = facing * 3.5;
    }
    else
    {
        // Ajuns la pozitie si pe sol → trece la stomp_idle
        x   = _tx;
        hsp = 0;
        if (_on_g) iele_attack = "stomp_idle";
    }

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
}
