// ── Blackboard ────────────────────────────────────────────────
if (instance_exists(oPlayer))
{
    bb_player_x = oPlayer.x;
    bb_player_y = oPlayer.y;
}

// ── Fight ended ───────────────────────────────────────────────
if (fight_ended)
{
    stomp_active = false;
    hora_active  = false;
    pp_active    = false;
    exit;
}

// ── Intro (inainte de lupta) ──────────────────────────────────
if (!fight_started)
{
    _intro_step();
    _manage_hora();
    exit;
}

// ── Detectie moarte Iele ──────────────────────────────────────
for (var _di = 0; _di < 3; _di++)
{
    if (!instance_exists(iele[_di])) continue;
    if (iele[_di].hp <= 0 && !iele[_di].is_dead)
        _iele_death(_di);
}

// ── Tranzitii de phase ────────────────────────────────────────
if (!phase2_triggered)
{
    for (var _pi = 0; _pi < 3; _pi++)
        if (instance_exists(iele[_pi]) && iele[_pi].hp <= iele[_pi].hp_max * 0.5)
            { boss_phase = 2; phase2_triggered = true; break; }
}
if (!phase3_triggered)
{
    for (var _pi = 0; _pi < 3; _pi++)
        if (instance_exists(iele[_pi]) && iele[_pi].hp <= iele[_pi].hp_max * 0.25)
            { boss_phase = 3; phase3_triggered = true; break; }
}

// ── Invincibility timer per Iela ──────────────────────────────
for (var _pi = 0; _pi < 3; _pi++)
    if (instance_exists(iele[_pi]) && iele[_pi].invincible_timer > 0)
        iele[_pi].invincible_timer--;

// ── Cooldown-uri ──────────────────────────────────────────────
if (cd_push > 0)     cd_push--;
if (cd_pingpong > 0) cd_pingpong--;
if (cd_hora > 0)     cd_hora--;
if (cd_stomp > 0 && cd_stomp < 9999) cd_stomp--;

// ── Phase 2 setup — o singura data la tranzitie ───────────────
if (phase2_triggered && !phase2_setup_done)
{
    phase2_setup_done = true;
    // Iela3 coboara de pe creanga
    if (instance_exists(iele[2]) && iele[2].iele_attack == "perch")
    {
        iele[2].vsp         = -2.2;
        iele[2].iele_attack = "dismount";
        perch_count         = 0;
    }
    phase2_iele3_on_perch = false;
    phase2_iele3_timer    = 900; // 15 sec in arena înainte de primul perch
}

// ── Phase 3 setup — o singura data la tranzitie ───────────────
if (phase3_triggered && !phase3_setup_done)
{
    phase3_setup_done = true;
    cd_stomp  = 0;           // stomp disponibil imediat
    attack_cd = min(attack_cd, 180); // atac combinat în 3 sec
}

// ── Phase 2+: Iela3 alterneaza perch / arena ──────────────────
if (boss_phase >= 2 && phase2_setup_done
&&  instance_exists(iele[2]) && !iele[2].is_dead)
{
    phase2_iele3_timer--;
    if (phase2_iele3_timer <= 0)
    {
        if (!phase2_iele3_on_perch) // era in arena → urca pe creanga
        {
            if (perch_count == 0)
            {
                perch_x = (arena_x1 + arena_x2) * 0.5;
                perch_y = instance_exists(iele[0]) ? (iele[0].y - 340) : (bb_player_y - 340);
                perch_count         = 1;
                iele[2].iele_attack = "perch";
            }
            phase2_iele3_on_perch = true;
            phase2_iele3_timer    = 600; // 10 sec pe creanga
        }
        else // era pe creanga → coboara
        {
            if (iele[2].iele_attack == "perch")
            {
                iele[2].vsp         = -2.2;
                iele[2].iele_attack = "dismount";
                perch_count         = 0;
            }
            phase2_iele3_on_perch = false;
            phase2_iele3_timer    = 900; // 15 sec in arena
        }
    }
}

// ── Phase 1: trimite Iela3 pe creanga dupa 5 sec ──────────────
if (!phase1_setup_done && boss_phase == 1)
{
    phase1_perch_timer--;
    if (phase1_perch_timer <= 0)
    {
        phase1_setup_done = true;
        if (instance_exists(iele[2]) && perch_count == 0)
        {
            perch_x = (arena_x1 + arena_x2) * 0.5;
            perch_y = instance_exists(iele[0]) ? (iele[0].y - 340) : (bb_player_y - 340);
            perch_count = 1;
            iele[2].iele_attack = "perch";
        }
    }
}

// ── Phase 1: push imediat dupa dispersia dramatica post-hora ──
if (phase1_push_pending && !hora_active && !pp_active && !stomp_active)
{
    phase1_push_timer--;
    if (phase1_push_timer <= 0)
    {
        phase1_push_pending = false;
        _set_scenario("push");
        scenario_timer = 240;
    }
}

// ── Selectie atac combinat ────────────────────────────────────
if (!stomp_active && !hora_active && !pp_active)
{
    if (attack_cd > 0)
        attack_cd--;
    else
    {
        _try_attack();
        if (boss_phase == 1)      attack_cd = 900;
        else if (boss_phase == 2) attack_cd = 540;
        else                      attack_cd = 300;
    }
}

// ── Trigger: Iela3 pe creanga + player departe >5 sec → Throw ─
if (instance_exists(iele[2]) && !iele[2].is_dead
&&  iele[2].iele_attack == "perch"
&&  !iele[2].throw_active && !iele[2].throw_fired)
{
    var _d3 = point_distance(bb_player_x, bb_player_y, iele[2].x, iele[2].y);
    if (_d3 > 300)
        iele3_far_timer++;
    else
        iele3_far_timer = 0;

    if (iele3_far_timer >= 300)
    {
        iele[2].throw_active = true;
        iele[2].throw_timer  = 20; // 0.33 sec telegraph
        iele[2].throw_fired  = false;
        iele3_far_timer      = 0;
    }
}
else
    iele3_far_timer = 0;

// ── Trigger: player sta pe loc >3 sec → Hora ─────────────────
if (instance_exists(oPlayer) && boss_phase >= 2
&&  !stomp_active && !hora_active && !pp_active)
{
    if (abs(bb_player_x - player_last_x) < 8 && abs(bb_player_y - player_last_y) < 8)
        player_still_timer++;
    else
    {
        player_still_timer = 0;
        player_last_x      = bb_player_x;
        player_last_y      = bb_player_y;
    }
    if (player_still_timer >= 180 && cd_hora <= 0)
    {
        _start_hora();
        cd_hora            = (boss_phase == 3) ? 900 : 1500;
        player_still_timer = 0;
    }
}
else
{
    player_still_timer = 0;
    player_last_x      = bb_player_x;
    player_last_y      = bb_player_y;
}

// ── Trigger: arc de la distanta >300px >8 sec → Stomp (Phase 3) ──
if (boss_phase == 3 && instance_exists(oPlayer)
&&  !stomp_active && !hora_active && !pp_active)
{
    var _min_dist_bow = 99999;
    for (var _bi = 0; _bi < 3; _bi++)
        if (instance_exists(iele[_bi]) && !iele[_bi].is_dead)
            _min_dist_bow = min(_min_dist_bow, point_distance(bb_player_x, bb_player_y, iele[_bi].x, iele[_bi].y));

    if (oPlayer.current_weapon == "bow" && _min_dist_bow > 300)
        bow_distance_timer++;
    else
        bow_distance_timer = 0;

    if (bow_distance_timer >= 480 && cd_stomp <= 0)
    {
        _start_stomp();
        cd_stomp           = 1200;
        bow_distance_timer = 0;
    }
}
else if (boss_phase < 3)
    bow_distance_timer = 0;

// ── TEST KEYS ─────────────────────────────────────────────────
if (keyboard_check_pressed(ord("P"))) _start_pingpong();
if (keyboard_check_pressed(ord("O"))) _start_hora();
if (keyboard_check_pressed(ord("I"))) _send_to_perch();
if (keyboard_check_pressed(ord("J"))) _dismount_from_perch();
if (keyboard_check_pressed(ord("K"))) _start_throw();
if (keyboard_check_pressed(ord("U"))) _start_stomp();

// ── GESTIONEAZA HORA ─────────────────────────────────────────
_manage_hora();

// ── GESTIONEAZA STOMP + SYNC + PLOAIA DE BOLOVANI ────────────────────────
if (stomp_active)
{
    // ── 1. Detecteaza cand toate 3 sunt in stomp_idle → porneste sync timer ──
    if (!stomp_sync_started)
    {
        var _all_idle = true;
        for (var _si = 0; _si < 3; _si++)
            if (!instance_exists(iele[_si]) || iele[_si].iele_attack != "stomp_idle")
                { _all_idle = false; break; }

        if (_all_idle)
        {
            stomp_sync_started = true;
            stomp_sync_timer   = 0;

            var _img_spd    = 0.15;
            var _max_frames = 0;
            for (var _si = 0; _si < 3; _si++)
                if (instance_exists(iele[_si]))
                    _max_frames = max(_max_frames, ceil(iele[_si].stomp_loop_frame / _img_spd));

            var _max_impact = 0;
            for (var _si = 0; _si < 3; _si++)
            {
                if (!instance_exists(iele[_si])) continue;
                var _fi = ceil(iele[_si].stomp_loop_frame / _img_spd);
                iele[_si].stomp_start_at    = _max_frames - _fi;
                iele[_si].stomp_started     = false;
                iele[_si].stomp_looping     = false;
                iele[_si].stomp_impact_done = false;
                var _impact_at = iele[_si].stomp_start_at + ceil(iele[_si].stomp_impact_frame / _img_spd);
                _max_impact = max(_max_impact, _impact_at);
            }
            stomp_shake_at = _max_impact;
        }
    }

    // ── 2. Avanseaza timer de sync ───────────────────────────────────────────
    if (stomp_sync_started)
    {
        stomp_sync_timer++;

        // Impact sincronizat — toate bat in acelasi moment
        if (stomp_sync_timer == stomp_shake_at)
        {
            if (instance_exists(oCamera)) ScreenShake(16, 26);

            // Particule masive la picioarele fiecarei Iele
            for (var _si = 0; _si < 3; _si++)
            {
                if (!instance_exists(iele[_si])) continue;
                var _ps = part_system_create_layer(iele[_si].layer, false);
                var _pt = part_type_create();
                part_type_shape(_pt, pt_shape_pixel);
                part_type_size(_pt, 3, 8, -0.1, 0);
                part_type_colour3(_pt, make_colour_rgb(190, 150, 90),
                                       make_colour_rgb(140, 100, 55),
                                       make_colour_rgb(90,  60, 30));
                part_type_alpha2(_pt, 1, 0);
                part_type_speed(_pt, 3, 9, -0.1, 0);
                part_type_direction(_pt, 0, 360, 0, 35);
                part_type_gravity(_pt, 0.35, 270);
                part_type_life(_pt, 28, 50);
                part_particles_create(_ps, iele[_si].x, iele[_si].y, _pt, 25);
                part_type_destroy(_pt);
            }
        }
    }

    // ── 3. Detecteaza cand toate 3 sunt in loop → porneste ploaia ───────────
    if (!stomp_rain_active && stomp_sync_started)
    {
        var _all_looping = true;
        for (var _si = 0; _si < 3; _si++)
            if (!instance_exists(iele[_si]) || !iele[_si].stomp_looping)
                { _all_looping = false; break; }

        if (_all_looping)
        {
            stomp_rain_active = true;
            stomp_rain_timer  = 0;
            stomp_rain_cd     = 0;
            if (instance_exists(oCamera)) ScreenShake(10, 20);
        }
    }

    // ── 4. Ploaia de bolovani ────────────────────────────────────────────────
    if (stomp_rain_active)
    {
        stomp_rain_timer++;
        if (stomp_rain_cd > 0) stomp_rain_cd--;

        // Shake pulsatoriu — cutremur continuu
        if (stomp_rain_timer mod 28 == 0 && instance_exists(oCamera))
            ScreenShake(7, 12);

        // Spawn grup de bolovani
        if (stomp_rain_cd <= 0)
        {
            stomp_rain_cd = irandom_range(22, 38);

            var _px    = instance_exists(oPlayer) ? oPlayer.x : (arena_x1 + arena_x2) * 0.5;
            var _cam_y = camera_get_view_y(view_camera[0]);
            var _count = irandom_range(2, 3);

            repeat (_count)
            {
                var _bx = clamp(_px + random_range(-220, 220), arena_x1 + 24, arena_x2 - 24);
                instance_create_layer(_bx, _cam_y - 80, "Enemies", oBoulder);
            }
        }

        // Sfarsit ploaie
        if (stomp_rain_timer >= stomp_rain_dur)
            _end_stomp();
    }
}

// ── Scenariile si urmarirea sunt oprite cat timp PP, Hora sau Stomp sunt active ──
if (!pp_active && !hora_active && !stomp_active)
{
    if (instance_exists(oPlayer))
    {
        var _min_dist = 99999;
        for (var _di = 0; _di < 3; _di++)
        {
            if (!instance_exists(iele[_di])) continue;
            var _d = point_distance(iele[_di].x, iele[_di].y, bb_player_x, bb_player_y);
            _min_dist = min(_min_dist, _d);
        }
        if (_min_dist > 380 && current_scenario != "urmarire")
            _set_scenario("urmarire");
    }

    scenario_timer--;
    if (scenario_timer <= 0)
        _pick_next_scenario();

    _manage_scenario();
}

// ────────────────────────────────────────────────────────────
// HELPER: alege scenariu urmator
// ────────────────────────────────────────────────────────────
// ── GESTIONEAZA PING PONG ATTACK ──────────────────────────────
if (pp_active)
{
    pp_timer++;
    switch (pp_phase)
    {
        case 0: // Asteapta pozitionarea ambelor
            if ((pp_left_ready && pp_right_ready) || pp_timer > 300)
            {
                pp_phase         = 1;
                pp_timer         = 0;
                pp_left_ready    = false;
                pp_right_ready   = false;
                // Semnal: left impinge
                if (pp_left_idx >= 0 && instance_exists(iele[pp_left_idx]))
                    iele[pp_left_idx].pp_push_now = true;
            }
            break;

        case 1: // Right impinge cand playerul AJUNGE aproape de ea (dinamic)
        {
            var _right_x = (pp_right_idx >= 0 && instance_exists(iele[pp_right_idx]))
                           ? iele[pp_right_idx].x : 99999;
            var _player_near_right = abs(bb_player_x - _right_x) < 130;

            if (_player_near_right || pp_timer > 220)
            {
                pp_phase        = 2;
                pp_timer        = 0;
                pp_hit_received = false;
                if (pp_right_idx >= 0 && instance_exists(iele[pp_right_idx]))
                    iele[pp_right_idx].pp_push_now = true;
            }
            break;
        }

        case 2: // Asteapta playerul sa ajunga inapoi la left, atunci impinge
        {
            var _left_x = (pp_left_idx >= 0 && instance_exists(iele[pp_left_idx]))
                          ? iele[pp_left_idx].x : -99999;
            var _player_near_left = abs(bb_player_x - _left_x) < 130;

            if (_player_near_left || pp_timer > 220)
            {
                pp_passes++;
                pp_timer        = 0;
                pp_hit_received = false;
                if (pp_passes >= 2)
                {
                    // Push final stanga, apoi sfarsit
                    pp_phase = 3;
                    if (pp_left_idx >= 0 && instance_exists(iele[pp_left_idx]))
                        iele[pp_left_idx].pp_push_now = true;
                }
                else
                {
                    pp_phase = 1;
                    if (pp_left_idx >= 0 && instance_exists(iele[pp_left_idx]))
                        iele[pp_left_idx].pp_push_now = true;
                }
            }
            break;
        }

        case 3: // Asteapta push-ul final al primei Iele, apoi sfarsit
            if (pp_timer > 120) _end_pingpong();
            break;
    }
}

// ────────────────────────────────────────────────────────────
function _start_pingpong()
{
    if (pp_active) return;
    pp_active        = true;
    pp_phase         = 0;
    pp_timer         = 0;
    pp_passes        = 0;
    pp_left_ready    = false;
    pp_right_ready   = false;
    pp_hit_received  = false;

    pp_left_idx  = _leftmost_iele();
    pp_right_idx = _rightmost_iele();

    // Pozitionare simetrica — right Iela va reactiona dinamic cand playerul soseste
    var _left_pos  = clamp(bb_player_x - 200, arena_x1 + 40, arena_x2 - 40);
    var _right_pos = clamp(bb_player_x + 241, arena_x1 + 40, arena_x2 - 40);

    if (pp_left_idx  >= 0) scenario_target_x[pp_left_idx]  = _left_pos;
    if (pp_right_idx >= 0) scenario_target_x[pp_right_idx] = _right_pos;

    for (var _i = 0; _i < 3; _i++)
    {
        if (!instance_exists(iele[_i])) continue;
        if (_i == pp_left_idx)       iele[_i].iele_attack = "pp_left";
        else if (_i == pp_right_idx) iele[_i].iele_attack = "pp_right";
        else                         iele[_i].iele_attack = "pp_watch";
    }
}

function _start_stomp()
{
    // Sorteaza Ielele dupa pozitia curenta (stanga → dreapta)
    var _sorted = [0, 1, 2];
    for (var _a = 0; _a < 2; _a++)
        for (var _b = _a + 1; _b < 3; _b++)
            if (instance_exists(iele[_sorted[_a]]) && instance_exists(iele[_sorted[_b]])
            &&  iele[_sorted[_a]].x > iele[_sorted[_b]].x)
            {
                var _tmp = _sorted[_a]; _sorted[_a] = _sorted[_b]; _sorted[_b] = _tmp;
            }

    // Pozitii pe sol — fixate in treimea dreapta a arenei
    var _cx      = lerp(arena_x1, arena_x2, 0.72);
    var _offsets = [-130, 0, 130];

    stomp_center_x = _cx;

    for (var _i = 0; _i < 3; _i++)
    {
        var _idx = _sorted[_i];
        if (!instance_exists(iele[_idx])) continue;
        scenario_target_x[_idx]       = _cx + _offsets[_i];
        iele[_idx].stomp_started      = false;
        iele[_idx].stomp_looping      = false;
        iele[_idx].stomp_impact_done  = false;
        iele[_idx].stomp_start_at     = 0;
        iele[_idx].stomp_wait         = 0;
        iele[_idx].iele_attack        = "stomp_form";
    }

    stomp_active       = true;
    stomp_rain_active  = false;
    stomp_rain_timer   = 0;
    stomp_rain_cd      = 0;
    stomp_sync_started = false;
    stomp_sync_timer   = -1;
    stomp_shake_at     = -1;
}

function _start_throw()
{
    // Activeaza aruncatul pe toate Ielele percuate
    for (var _i = 0; _i < perch_count; _i++)
    {
        if (!instance_exists(iele[_i])) continue;
        iele[_i].throw_active = true;
        iele[_i].throw_timer  = irandom_range(0, 30); // offset ca sa nu arunce simultan
        iele[_i].throw_fired  = false;
    }
}

function _dismount_from_perch()
{
    if (perch_count <= 0) return;
    perch_count--;
    var _idx = perch_count;
    if (!instance_exists(iele[_idx])) return;

    iele[_idx].vsp         = -2.2; // hop initial dramatic
    iele[_idx].iele_attack = "dismount";
}

function _send_to_perch()
{
    if (perch_count >= 3) return;

    // La primul apas: calculeaza pozitia perch (mijlocul arenei, elevat)
    if (perch_count == 0)
    {
        perch_x = (arena_x1 + arena_x2) * 0.5;
        // Ia y-ul de la Iela 0 ca referinta pentru sol, urcam de acolo
        perch_y = instance_exists(iele[0]) ? (iele[0].y - 340) : (bb_player_y - 340);
    }

    var _idx = perch_count; // 0, 1, 2 in ordine
    if (!instance_exists(iele[_idx])) { perch_count++; return; }

    iele[_idx].iele_attack = "perch";
    perch_count++;
}

function _start_hora()
{
    if (hora_active || pp_active) return;
    hora_active  = true;
    hora_phase   = 0;
    hora_timer   = 0;

    // Centrul formatiei: langa player, clamped in arena
    hora_center_x = clamp(bb_player_x, arena_x1 + 144, arena_x2 - 144);

    // Sorteaza Ielele dupa pozitia curenta (stanga → dreapta)
    var _sorted = [0, 1, 2];
    for (var _a = 0; _a < 2; _a++)
        for (var _b = _a + 1; _b < 3; _b++)
            if (instance_exists(iele[_sorted[_a]]) && instance_exists(iele[_sorted[_b]])
            &&  iele[_sorted[_a]].x > iele[_sorted[_b]].x)
            {
                var _tmp = _sorted[_a]; _sorted[_a] = _sorted[_b]; _sorted[_b] = _tmp;
            }

    // Asigneaza pozitii: stanga, centru, dreapta
    var _offsets = [-72, 0, 72];
    for (var _i = 0; _i < 3; _i++)
    {
        var _idx = _sorted[_i];
        if (!instance_exists(iele[_idx])) continue;
        scenario_target_x[_idx] = hora_center_x + _offsets[_i];
        iele[_idx].iele_attack   = "hora";
    }
}

function _end_hora()
{
    hora_active           = false;
    intro_vignette_active = false;
    intro_vignette_timer  = 0;    // stinge vigneta garantat

    with (oHora) instance_destroy();

    for (var _i = 0; _i < 3; _i++)
    {
        if (!instance_exists(iele[_i])) continue;
        iele[_i].visible     = true;
        iele[_i].iele_attack = "none";
        iele[_i].hsp         = 0;
    }

    // Phase 1: moment dramatic — toate 3 se desfac, push urmeaza cu controale inversate
    if (boss_phase == 1 && phase1_setup_done
    &&  instance_exists(iele[2]) && !iele[2].is_dead)
    {
        iele[2].iele_attack = "perch";
        perch_count = 1;

        if (instance_exists(oCamera)) ScreenShake(10, 22);

        // Iela1 si Iela2 dashaza rapid la marginile arenei
        _set_scenario("liniste");
        if (instance_exists(iele[0]))
        {
            iele[0].prev_scenario_role = "";
            scenario_role[0]           = "dash_to";
            scenario_target_x[0]       = arena_x1 + 80;
        }
        if (instance_exists(iele[1]))
        {
            iele[1].prev_scenario_role = "";
            scenario_role[1]           = "dash_to";
            scenario_target_x[1]       = arena_x2 - 80;
        }
        scenario_timer       = 9999;
        phase1_push_pending  = true;
        phase1_push_timer    = 150;
        return;
    }

    // Respiro normal dupa hora (Phase 2+)
    _set_scenario("liniste");
    scenario_timer = irandom_range(180, 260);
}

function _end_pingpong()
{
    pp_active = false;
    for (var _i = 0; _i < 3; _i++)
    {
        if (!instance_exists(iele[_i])) continue;
        iele[_i].iele_attack  = "none";
        iele[_i].pp_push_now  = false;
        iele[_i].push_hit     = false;
        iele[_i].hsp          = 0;
    }
    pp_left_idx  = -1;
    pp_right_idx = -1;

    // Respiro dupa ping pong
    _set_scenario("liniste");
    scenario_timer = irandom_range(150, 220);
}

// ────────────────────────────────────────────────────────────
function _pick_next_scenario()
{
    var _names   = ["liniste", "schimb", "dus_intors", "una_zboara", "apropierea", "rand_pe_rand", "push"];
    var _weights = [3, 2, 2, 2, 1, 1, 3];

    // Exclude ultimul scenariu (anti-repeat)
    for (var _i = 0; _i < array_length(_names); _i++)
        if (_names[_i] == last_scenario) _weights[_i] = 0;

    var _next = weighted_pick(_names, _weights);
    _set_scenario(_next);
}

// ────────────────────────────────────────────────────────────
// HELPER: porneste un scenariu
// ────────────────────────────────────────────────────────────
function _set_scenario(_name)
{
    last_scenario    = current_scenario;
    current_scenario = _name;
    scenario_phase   = 0;
    scenario_phase_t = 0;

    // Reset roluri
    for (var _i = 0; _i < 3; _i++) scenario_role[_i] = "idle";

    switch (_name)
    {
        case "liniste":
            // Toate 3 idle 5-6 sec
            scenario_timer = irandom_range(300, 380);
            // Toate ramann idle (deja setate)
            break;

        case "schimb":
            // Stanga face skip, dreapta face dash — se incruciseaza
            scenario_timer = 280;
            var _li = _leftmost_iele();
            var _ri = _rightmost_iele();
            if (_li >= 0)
            {
                scenario_role[_li]     = "skip_to";
                scenario_target_x[_li] = clamp(bb_player_x + 260, arena_x1 + 40, arena_x2 - 40);
            }
            if (_ri >= 0)
            {
                scenario_role[_ri]     = "dash_to";
                scenario_target_x[_ri] = clamp(bb_player_x - 260, arena_x1 + 40, arena_x2 - 40);
            }
            break;

        case "dus_intors":
            // Una face dash departe, pauza, dash inapoi
            scenario_timer = 400;
            scenario_phase = 0; // 0=dus, 1=pauza, 2=intors
            var _ai = _any_iele_with_dash();
            if (_ai >= 0)
            {
                scenario_role[_ai]     = "dash_to";
                var _far = (iele[_ai].x < bb_player_x)
                         ? clamp(bb_player_x + 320, arena_x1 + 40, arena_x2 - 40)
                         : clamp(bb_player_x - 320, arena_x1 + 40, arena_x2 - 40);
                scenario_target_x[_ai] = _far;
                // Salveaza indexul si pozitia originala pentru faza de intors
                scenario_target_x[(_ai + 1) mod 3] = iele[_ai].x; // reuse slot pentru origin
            }
            break;

        case "una_zboara":
            // Una face jump inalt, celelalte idle
            scenario_timer = 260;
            var _ji = irandom(2);
            while (!instance_exists(iele[_ji])) _ji = (_ji + 1) mod 3;
            scenario_role[_ji]     = "jump";
            scenario_target_x[_ji] = clamp(
                bb_player_x + ((iele[_ji].x < bb_player_x) ? 200 : -200),
                arena_x1 + 40, arena_x2 - 40);
            break;

        case "apropierea":
            // Toate 3 walk spre player, stop la ~200px
            scenario_timer = 360;
            for (var _i = 0; _i < 3; _i++)
            {
                if (!instance_exists(iele[_i])) continue;
                var _side = (iele[_i].x < bb_player_x) ? -1 : 1;
                scenario_role[_i]     = "walk_to";
                scenario_target_x[_i] = clamp(bb_player_x + _side * 200,
                                               arena_x1 + 40, arena_x2 - 40);
            }
            break;

        case "rand_pe_rand":
            // Secvential: A dash → pauza → B skip → pauza → C jump
            scenario_timer = 480;
            scenario_phase = 0;
            scenario_phase_t = 0;
            // Faza 0: prima Iela face dash
            if (instance_exists(iele[0]))
            {
                scenario_role[0]     = "dash_to";
                scenario_target_x[0] = clamp(
                    bb_player_x + ((iele[0].x < bb_player_x) ? 220 : -220),
                    arena_x1 + 40, arena_x2 - 40);
            }
            break;

        case "pingpong":
            // 2 Iele se flancheaza, paseaza player ul intre ele
            scenario_timer = 600;
            pp_phase       = 0;
            pp_timer       = 0;
            pp_passes      = 0;

            // Alege left si right bazat pe pozitie
            pp_left_idx  = _leftmost_iele();
            pp_right_idx = _rightmost_iele();
            var _pp_w = -1;
            for (var _ppi = 0; _ppi < 3; _ppi++)
            {
                if (_ppi != pp_left_idx && _ppi != pp_right_idx && instance_exists(iele[_ppi]))
                    _pp_w = _ppi;
            }

            if (pp_left_idx >= 0)
            {
                scenario_role[pp_left_idx]     = "pp_left";
                scenario_target_x[pp_left_idx] = clamp(bb_player_x - 180, arena_x1+40, arena_x2-40);
            }
            if (pp_right_idx >= 0)
            {
                scenario_role[pp_right_idx]     = "pp_right";
                scenario_target_x[pp_right_idx] = clamp(bb_player_x + 260, arena_x1+40, arena_x2-40);
            }
            if (_pp_w >= 0) scenario_role[_pp_w] = "idle";
            break;

        case "urmarire":
            // Player e departe — una dash rapid, celelalte 2 vin mai incet
            scenario_timer = 240;
            var _dash_i  = _any_iele_with_dash();
            var _side_px = bb_player_x;

            for (var _i = 0; _i < 3; _i++)
            {
                if (!instance_exists(iele[_i])) continue;
                var _offset = (_i == 0) ? -160 : (_i == 1 ? 0 : 160);

                if (_i == _dash_i)
                {
                    // Ielă cu dash ajunge prima
                    scenario_role[_i]     = "dash_to";
                    scenario_target_x[_i] = clamp(_side_px + _offset, arena_x1 + 40, arena_x2 - 40);
                }
                else
                {
                    // Celelalte vin cu skip
                    scenario_role[_i]     = "skip_to";
                    scenario_target_x[_i] = clamp(_side_px + _offset, arena_x1 + 40, arena_x2 - 40);
                }
            }
            break;

        case "push":
            // O Iela da push, celelalte idle
            scenario_timer = 220;
            var _pi = _closest_iele_to_player();
            if (_pi >= 0)
            {
                scenario_role[_pi]     = "push";
                scenario_target_x[_pi] = bb_player_x;
            }
            break;
    }
}

// ────────────────────────────────────────────────────────────
// HELPER: gestioneaza sub-fazele scenariilor complexe
// ────────────────────────────────────────────────────────────
function _manage_scenario()
{
    scenario_phase_t++;

    switch (current_scenario)
    {
        case "pingpong":
            pp_timer++;
            var _pl = (pp_left_idx  >= 0 && instance_exists(iele[pp_left_idx]))  ? iele[pp_left_idx]  : noone;
            var _pr = (pp_right_idx >= 0 && instance_exists(iele[pp_right_idx])) ? iele[pp_right_idx] : noone;

            switch (pp_phase)
            {
                case 0:
                    // Tintele sunt fixate la start — verifica doar daca au ajuns
                    var _lok = (_pl != noone) && abs(_pl.x - scenario_target_x[pp_left_idx])  < 55;
                    var _rok = (_pr != noone) && abs(_pr.x - scenario_target_x[pp_right_idx]) < 55;

                    if ((_lok && _rok) || pp_timer > 300)
                    {
                        pp_phase = 1; pp_timer = 0;
                        if (_pl != noone) _pl.pp_push_now = true;
                    }
                    break;

                case 1:
                    // Right trebuie sa fie in pozitie inainte sa prinda playerul
                    if (pp_right_idx >= 0) scenario_target_x[pp_right_idx] = clamp(bb_player_x + 260, arena_x1+40, arena_x2-40);
                    var _rok1 = (_pr != noone) && abs(_pr.x - scenario_target_x[pp_right_idx]) < 60;

                    // Asteapta playerul sa ajunga la right SAU timeout
                    if (_pr != noone && _rok1 && (abs(bb_player_x - _pr.x) < 130 || pp_timer > 180))
                    {
                        pp_phase = 2; pp_timer = 0;
                        _pr.pp_push_now = true;
                    }
                    else if (pp_timer > 200) { pp_phase = 2; pp_timer = 0; if (_pr != noone) _pr.pp_push_now = true; }
                    break;

                case 2:
                    pp_passes++;
                    if (pp_passes >= 2)
                        _set_scenario("liniste");
                    else
                    {
                        // Left trebuie sa fie inapoi in pozitie
                        if (pp_left_idx >= 0) scenario_target_x[pp_left_idx] = clamp(bb_player_x - 180, arena_x1+40, arena_x2-40);
                        pp_phase = 1; pp_timer = 0;
                        if (_pl != noone) _pl.pp_push_now = true;
                    }
                    break;
            }
            break;

        case "dus_intors":
            // Faza 0=dus, dupa 120 frames→pauza, dupa 60→intors
            if (scenario_phase == 0 && scenario_phase_t >= 120)
            {
                scenario_phase   = 1; // pauza
                scenario_phase_t = 0;
                for (var _i = 0; _i < 3; _i++) scenario_role[_i] = "idle";
            }
            else if (scenario_phase == 1 && scenario_phase_t >= 80)
            {
                scenario_phase   = 2; // intors
                scenario_phase_t = 0;
                var _ai = _any_iele_with_dash();
                if (_ai >= 0)
                {
                    // Intoarce-te la pozitia originala (salvata in slot adiacent)
                    var _slot_origin = (_ai + 1) mod 3;
                    scenario_role[_ai]     = "dash_to";
                    scenario_target_x[_ai] = scenario_target_x[_slot_origin];
                }
            }
            break;

        case "rand_pe_rand":
            // Faza 0=A dash(t<100), 1=pauza(t<160), 2=B skip, 3=pauza, 4=C jump
            if (scenario_phase == 0 && scenario_phase_t >= 100)
            {
                scenario_phase   = 1;
                scenario_phase_t = 0;
                for (var _i = 0; _i < 3; _i++) scenario_role[_i] = "idle";
            }
            else if (scenario_phase == 1 && scenario_phase_t >= 60)
            {
                scenario_phase   = 2;
                scenario_phase_t = 0;
                if (instance_exists(iele[1]))
                {
                    scenario_role[1]     = "skip_to";
                    scenario_target_x[1] = clamp(
                        bb_player_x + ((iele[1].x < bb_player_x) ? 200 : -200),
                        arena_x1 + 40, arena_x2 - 40);
                }
            }
            else if (scenario_phase == 2 && scenario_phase_t >= 100)
            {
                scenario_phase   = 3;
                scenario_phase_t = 0;
                for (var _i = 0; _i < 3; _i++) scenario_role[_i] = "idle";
            }
            else if (scenario_phase == 3 && scenario_phase_t >= 60)
            {
                scenario_phase   = 4;
                scenario_phase_t = 0;
                if (instance_exists(iele[2]))
                {
                    scenario_role[2]     = "jump";
                    scenario_target_x[2] = clamp(
                        bb_player_x + ((iele[2].x < bb_player_x) ? 200 : -200),
                        arena_x1 + 40, arena_x2 - 40);
                }
            }
            break;
    }
}

// ────────────────────────────────────────────────────────────
function _end_stomp()
{
    stomp_active       = false;
    stomp_rain_active  = false;
    stomp_rain_timer   = 0;
    stomp_rain_cd      = 0;
    stomp_sync_started = false;
    stomp_sync_timer   = -1;
    stomp_shake_at     = -1;

    // Bolovanii in aer: distruge imediat (sunt off-screen)
    // Bolovanii pe sol (linger_timer >= 0): lasa-i sa dispara natural —
    // fiecare a aterizat la un moment diferit, deci au linger_timer diferit → staggered fade
    with (oBoulder)
    {
        if (linger_timer < 0)
            instance_destroy();
        // altfel: boulder-ul e pe sol si se va distruge singur cand linger_timer ajunge la 0
    }

    // Trimite Ielele inapoi la orbit
    for (var _i = 0; _i < 3; _i++)
    {
        if (!instance_exists(iele[_i])) continue;
        iele[_i].iele_attack      = "none";
        iele[_i].stomp_started    = false;
        iele[_i].stomp_looping    = false;
        iele[_i].stomp_wait       = 0;
        iele[_i].iele_phase       = "orbit";
        iele[_i].iele_state       = "idle";
        iele[_i].orbit_move_timer = irandom_range(60, 120);
        iele[_i].hsp              = 0;
    }

    _set_scenario("liniste");
    scenario_timer = irandom_range(200, 320);
}

// ────────────────────────────────────────────────────────────
// HELPERS: cautare Iele
// ────────────────────────────────────────────────────────────
function _leftmost_iele()
{
    var _best = -1; var _bx = 999999;
    for (var _i = 0; _i < 3; _i++)
        if (instance_exists(iele[_i]) && iele[_i].x < _bx) { _bx = iele[_i].x; _best = _i; }
    return _best;
}
function _rightmost_iele()
{
    var _best = -1; var _bx = -999999;
    for (var _i = 0; _i < 3; _i++)
        if (instance_exists(iele[_i]) && iele[_i].x > _bx) { _bx = iele[_i].x; _best = _i; }
    return _best;
}
function _any_iele_with_dash()
{
    for (var _i = 0; _i < 3; _i++)
        if (instance_exists(iele[_i]) && iele[_i].spr_dash != -1) return _i;
    return 0;
}
function _closest_iele_to_player()
{
    var _best = -1; var _bd = 999999;
    for (var _i = 0; _i < 3; _i++)
    {
        if (!instance_exists(iele[_i])) continue;
        var _d = point_distance(iele[_i].x, iele[_i].y, bb_player_x, bb_player_y);
        if (_d < _bd) { _bd = _d; _best = _i; }
    }
    return _best;
}

// ────────────────────────────────────────────────────────────
// Moartea unei Iele + efecte în lant
// ────────────────────────────────────────────────────────────
function _iele_death(_idx)
{
    if (!instance_exists(iele[_idx])) return;

    iele[_idx].is_dead     = true;
    iele[_idx].hp          = 0;
    iele[_idx].iele_attack = "none";
    iele[_idx].hsp         = 0;

    // Opreste orice atac combinat activ
    if (hora_active)  _end_hora();
    if (pp_active)    _end_pingpong();
    if (stomp_active) _end_stomp();

    switch (_idx)
    {
        case 0: // Iela1 moare → Iela2 rage buff
            iele1_dead = true;
            if (instance_exists(iele[1]))
            {
                iele[1].rage_active = true;
                // Rage: cooldown-uri reduse imediat
                cd_hora     = min(cd_hora,     300);
                cd_pingpong = min(cd_pingpong, 180);
                attack_cd   = min(attack_cd,   120);
            }
            break;

        case 1: // Iela2 moare → Iela3 fuge, fight se termina
            iele2_dead = true;
            if (instance_exists(iele[2]))
                iele[2].iele_attack = "flee";
            break;

        case 2: // Iela3 moare
            iele3_dead = true;
            break;
    }
}

// ────────────────────────────────────────────────────────────
// Gestioneaza hora (combat + intro)
// ────────────────────────────────────────────────────────────
function _manage_hora()
{
    if (!hora_active) return;

    hora_timer++;
    switch (hora_phase)
    {
        case 0: // Asteapta pozitionarea
        {
            var _all_ready = true;
            for (var _i = 0; _i < 3; _i++)
            {
                if (!instance_exists(iele[_i])) continue;
                if (abs(iele[_i].x - scenario_target_x[_i]) > 16) { _all_ready = false; break; }
            }
            if (_all_ready || hora_timer > 300)
            {
                hora_phase = 1;
                hora_timer = 0;
                var _ref_y = (instance_exists(iele[0])) ? iele[0].y : bb_player_y;
                for (var _i = 0; _i < 3; _i++)
                    if (instance_exists(iele[_i])) iele[_i].visible = false;
                if (!instance_exists(oHora))
                    instance_create_layer(hora_center_x, _ref_y, "Enemies", oHora);
            }
            break;
        }
        case 1:
            break;
    }
}

// ────────────────────────────────────────────────────────────
// Secventa de intro (inainte de fight_started)
// ────────────────────────────────────────────────────────────
function _intro_step()
{
    switch (intro_step)
    {
        case 0: // Asteapta trigger la intrarea in arena
            if (intro_triggered)
            {
                var _mid = (arena_x1 + arena_x2) * 0.5;
                for (var _i = 0; _i < 3; _i++)
                {
                    if (!instance_exists(iele[_i])) continue;
                    iele[_i].intro_bounces    = 0;
                    iele[_i].intro_at_wall    = false;
                    iele[_i].intro_walk_phase = "patrol";
                    iele[_i].intro_pat_dir    = (iele[_i].x < _mid) ? 1 : -1;
                }
                intro_step  = 1;
                intro_timer = 0;
            }
            break;

        case 1: // Ielele se gestioneaza singure — patrula + mers la centru
        {
            var _all_waiting = true;
            for (var _i = 0; _i < 3; _i++)
            {
                if (!instance_exists(iele[_i])) continue;
                if (iele[_i].intro_walk_phase != "wait") { _all_waiting = false; break; }
            }

            if (_all_waiting)
            {
                intro_timer++;
                if (intro_timer >= 30)
                {
                    for (var _i = 0; _i < 3; _i++)
                        if (instance_exists(iele[_i])) iele[_i].hsp = 0;
                    intro_step  = 2;
                    intro_timer = 0;
                    _start_hora();

                    var _max_d = 0;
                    for (var _i = 0; _i < 3; _i++)
                        if (instance_exists(iele[_i]))
                            _max_d = max(_max_d, abs(scenario_target_x[_i] - iele[_i].x));
                    intro_sync_dur = max(140, ceil(_max_d / 1.6));
                }
            }
            else
                intro_timer = 0;
            break;
        }
        case 2: // Hora se formeaza — Ielele merg spre pozitia de hora
            intro_timer++;

            // Conduce Ielele sincronizat — toate ajung in acelasi timp
            if (!instance_exists(oHora))
            {
                var _rem = max(1, intro_sync_dur - intro_timer);
                for (var _i = 0; _i < 3; _i++)
                {
                    if (!instance_exists(iele[_i])) continue;
                    var _ie2 = iele[_i];
                    var _dx2 = scenario_target_x[_i] - _ie2.x;
                    if (abs(_dx2) > 8)
                        _ie2.hsp = clamp(_dx2 / _rem, -2.5, 2.5);
                    else
                    {
                        _ie2.x   = scenario_target_x[_i];
                        _ie2.hsp = 0;
                    }
                }
            }

            if ((instance_exists(oHora) && intro_timer >= 300) || intro_timer >= 520)
            {
                for (var _i = 0; _i < 3; _i++)
                    if (instance_exists(iele[_i])) iele[_i].hsp = 0;
                intro_step            = 3;
                intro_timer           = 0;
                intro_dialog_visible  = true;
                intro_vignette_active = true;
                intro_vignette_timer  = 720; // max 12 sec — backup daca _end_hora intarzie
            }
            break;

        case 3: // Dialog — player apasa E → Ielele pornesc DIN POZITIA HOREI spre player
            if (keyboard_check_pressed(ord("E")))
            {
                intro_dialog_visible = false;
                fight_started        = true;
                cd_hora              = 1500;

                // Salveaza centrul horei de intro — acolo vor aparea Ielele
                var _hora_start_x = hora_center_x;

                // Distruge oHora din intro — _manage_hora() va crea una noua
                // la hora_center_x abia cand Ielele ajung fizic la player
                hora_center_x = clamp(bb_player_x, arena_x1 + 144, arena_x2 - 144);
                if (instance_exists(oHora))
                    instance_destroy(oHora);

                hora_phase = 0;
                hora_timer = 0;

                // Fa Ielele vizibile la pozitia horei de intro si trimite-le spre player
                var _sorted_e = [0, 1, 2];
                for (var _ae = 0; _ae < 2; _ae++)
                    for (var _be = _ae + 1; _be < 3; _be++)
                        if (instance_exists(iele[_sorted_e[_ae]]) && instance_exists(iele[_sorted_e[_be]])
                        &&  iele[_sorted_e[_ae]].x > iele[_sorted_e[_be]].x)
                        {
                            var _tmp_e     = _sorted_e[_ae];
                            _sorted_e[_ae] = _sorted_e[_be];
                            _sorted_e[_be] = _tmp_e;
                        }

                var _off_e = [-72, 0, 72];
                for (var _ie = 0; _ie < 3; _ie++)
                {
                    var _idx_e = _sorted_e[_ie];
                    if (!instance_exists(iele[_idx_e])) continue;
                    iele[_idx_e].x            = _hora_start_x + _off_e[_ie]; // din pozitia horei de intro
                    iele[_idx_e].hsp          = 0;
                    iele[_idx_e].visible      = true;
                    iele[_idx_e].iele_attack  = "hora";
                    scenario_target_x[_idx_e] = hora_center_x + _off_e[_ie]; // spre player
                }
            }
            break;
    }
}

// ────────────────────────────────────────────────────────────
// Selectie atac combinat bazata pe phase si cooldown-uri
// ────────────────────────────────────────────────────────────
function _try_attack()
{
    switch (boss_phase)
    {
        case 1:
            // Phase 1: hora o singura data ca preview
            if (!hora_preview_done && cd_hora <= 0)
            {
                _start_hora();
                cd_hora           = 9999; // nu se mai repeta in phase 1
                hora_preview_done = true;
            }
            break;

        case 2:
        {
            // Phase 2: hora + ping pong disponibile
            var _pool = [];
            if (cd_hora <= 0)     array_push(_pool, "hora");
            if (cd_pingpong <= 0) array_push(_pool, "pp");
            if (array_length(_pool) == 0) break;

            var _pick = _pool[irandom(array_length(_pool) - 1)];
            switch (_pick)
            {
                case "hora": _start_hora();     cd_hora     = 1500; break;
                case "pp":   _start_pingpong(); cd_pingpong = 720;  break;
            }
            break;
        }

        case 3:
        {
            // Phase 3: toate atacurile, cooldown-uri reduse
            var _pool3 = [];
            if (cd_hora <= 0)     array_push(_pool3, "hora");
            if (cd_pingpong <= 0) array_push(_pool3, "pp");
            if (cd_stomp <= 0)    array_push(_pool3, "stomp");
            if (array_length(_pool3) == 0) break;

            var _pick3 = _pool3[irandom(array_length(_pool3) - 1)];
            switch (_pick3)
            {
                case "hora":  _start_hora();     cd_hora     = 900;  break;
                case "pp":    _start_pingpong(); cd_pingpong = 480;  break;
                case "stomp": _start_stomp();    cd_stomp    = 1200; break;
            }
            break;
        }
    }
}
