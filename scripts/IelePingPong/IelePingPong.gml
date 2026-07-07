/// @func IelePingPong()
/// Apelat din IeleUpdate cand iele_attack = "pp_left" / "pp_right" / "pp_watch"
/// Gestioneaza rolul individual al Ielei in atacul Ping Pong
function IelePingPong()
{
    var _ctrl = instance_exists(oBoss3Controller);
    var _px   = instance_exists(oPlayer) ? oPlayer.x : x;
    var _on_g = place_meeting(x, y + 1, oWall);

    image_yscale = image_yscale_base;

    // ── WATCH — pluteste sus cat timp se desfasoara atacul ───────
    if (iele_attack == "pp_watch")
    {
        hsp          = 0;
        sprite_index = spr_idle;
        image_speed  = 0.12;
        image_xscale = (_px >= x) ? -image_xscale_base : image_xscale_base;

        // Gaseste solul si urca la 160px deasupra
        var _ground = y;
        for (var _gs = 0; _gs < 500; _gs += 4)
            if (place_meeting(x, y + _gs, oWall)) { _ground = y + _gs; break; }

        var _target_y = _ground - 160;
        y = lerp(y, _target_y, 0.04); // drift lin in sus

        return;
    }

    // ── PP_LEFT / PP_RIGHT ──────────────────────────────────────
    var _is_left = (iele_attack == "pp_left");
    // Tinta e fixata de controller la start — nu recalculata dinamic
    var _target  = _ctrl ? oBoss3Controller.scenario_target_x[my_index]
                         : (_is_left ? (_px - 200) : (_px + 200));

    // Fizica verticala (gravitatie + coliziune)
    vsp += grv;
    if (place_meeting(x, y + vsp, oWall))
    {
        while (!place_meeting(x, y + sign(vsp), oWall)) y += sign(vsp);
        vsp = 0;
    }
    else y += vsp;
    y = floor(y);

    // ── FAZA: POZITIONARE ───────────────────────────────────────
    if (sprite_index != spr_push)
    {
        var _dist = abs(x - _target);

        if (_dist > 20 && !pp_push_now && !pp_has_pushed)
        {
            // Mergi la pozitie cu skip (doar inainte de primul push)
            facing       = (_target > x) ? 1 : -1;
            sprite_index = spr_skip;
            image_speed  = 0.18;
            image_xscale = -facing * image_xscale_base;
            hsp          = facing * 2;
        }
        else if (!pp_push_now)
        {
            // In pozitie — stai si asteapta
            hsp          = 0;
            sprite_index = spr_idle;
            image_speed  = 0.12;
            image_xscale = (_px >= x) ? -image_xscale_base : image_xscale_base;

            var _b2 = sin((current_time / 700.0) + bob_offset) * 0.2;
            if (!place_meeting(x, y + _b2, oWall)) y += _b2;

            // Semnaleaza controllerului ca sunt in pozitie
            if (_ctrl)
            {
                if (_is_left)  oBoss3Controller.pp_left_ready  = true;
                else           oBoss3Controller.pp_right_ready = true;
            }
        }

        // ── SEMNAL PUSH PRIMIT → charge sau push direct ─────────
        if (pp_push_now)
        {
            pp_push_now   = false;
            pp_has_pushed = false;
            push_dir      = _is_left ? 1 : -1;
            push_hit      = false;
            image_index   = 0;
            image_xscale  = -push_dir * image_xscale_base;

            if (abs(x - _px) < 150)
            {
                // Player aproape (vine spre ea) — merge direct la push, fara charge
                pp_charging  = false;
                sprite_index = spr_push;
                image_speed  = 0.4;
                hsp          = 0;
            }
            else
            {
                // Player departe — charge spre el
                pp_charging  = true;
                sprite_index = spr_skip;
                image_speed  = 0.3;
                hsp          = push_dir * 4;
            }
        }
    }

    // ── FAZA: CHARGE (se apropie de player inainte de push) ────
    if (pp_charging)
    {
        hsp          = push_dir * 4;
        image_xscale = -push_dir * image_xscale_base; // fata spre directia de mers
        sprite_index = spr_skip;
        image_speed  = 0.3;

        // Cand e aproape de player → trece la animatia de push
        if (abs(x - _px) < 50)
        {
            pp_charging  = false;
            push_hit     = false;
            sprite_index = spr_push;
            image_index  = 0;
            image_speed  = 0.4;
            image_xscale = -push_dir * image_xscale_base;
            hsp          = 0;
        }
    }

    // ── FAZA: ANIMATIE PUSH ─────────────────────────────────────
    if (sprite_index == spr_push && !pp_charging)
    {
        image_xscale = -push_dir * image_xscale_base;
        hsp          = push_dir * 0.3;

        var _fi = floor(image_index);

        // Hit Stop — ingheata animatia la impact (crisp feel)
        if (pp_hit_stop > 0)
        {
            pp_hit_stop--;
            image_speed = 0;
        }
        else
        {
            // Variatie image_speed: anticipare lenta → impact rapid → recovery
            if (_fi < 3)       image_speed = 0.2;  // anticipare
            else if (_fi < 7)  image_speed = 0.6;  // impact rapid
            else               image_speed = 0.3;  // recovery
        }

        // Detectie palma → damage + hit stop
        var _pw    = x + palm_spr_dx * image_xscale;
        var _pdist = instance_exists(oPlayer) ? abs(_pw - oPlayer.x) : 999;

        if (_fi > 2 && _pdist < 90 && !push_hit)
        {
            push_hit    = true;
            pp_hit_stop = 5; // 5 frame-uri freeze pe impact

            if (instance_exists(oPlayer))
            with (oPlayer)
            {
                pushed_dir   = other.push_dir;
                pushed_timer = 50;
                hp          -= 1;
                flash        = 8;
            }

            if (instance_exists(oCamera)) ScreenShake(4, 8);
            if (_ctrl) oBoss3Controller.pp_hit_received = true;
        }

        if (animation_end())
        {
            hsp           = 0;
            push_hit      = false;
            pp_hit_stop   = 0;
            pp_has_pushed = true; // ramane pe loc dupa push
            sprite_index  = spr_idle;
            image_speed   = 0.12;
        }
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
