/// @func IeleUpdate()
/// Sistem bazat pe timere per-Iela:
/// ORBIT (show, independent) → timer expira → RUSH → PUSH → FLEE → ORBIT
function IeleUpdate()
{
    var _on_ground = place_meeting(x, y + 1, oWall);
    var _ctrl      = instance_exists(oBoss3Controller);
    var _cmd       = _ctrl ? oBoss3Controller.command : "wander";
    var _px        = instance_exists(oPlayer) ? oPlayer.x : x;
    var _py        = instance_exists(oPlayer) ? oPlayer.y : y;

    // Reset implicit — SINGURUL loc din tot codul care seteaza image_angle
    // e zborul spre creanga (IelePerch.gml, "IN ZBOR"), care il recalculeaza
    // din nou in ACELASI frame daca iele_attack=="perch" si inca in zbor (mai
    // jos), deci reset-ul de aici nu produce niciun flicker vizual. Fara el,
    // image_angle ramanea agatat de ultima valoare din zbor pe orice alta
    // tranzitie care nu trece prin resetarile proprii ale IelePerch (sosire/
    // dismount) — ex. hora/stomp/pingpong pornite direct din perch — stricand
    // vizual toate animatiile ulterioare (image_angle e proprietate de
    // instanta, nu de sprite).
    image_angle = 0;

    // ── ATTACK STATE — complet separat de orbit ───────────────────
    if (iele_attack != "none")
    {
        if      (iele_attack == "hora")                    IeleHora();
        else if (iele_attack == "perch"
             ||  iele_attack == "dismount")               IelePerch();
        else if (iele_attack == "stomp_form"
             ||  iele_attack == "stomp_idle")             IeleStomp();
        else                                              IelePingPong();
        return;
    }

    // ── FIZICA ────────────────────────────────────────────────
    // Gravitatie oprita in idle (levitare), altfel mereu activa (incl. in dash → arc)
    if (iele_phase == "orbit" && iele_state == "idle")
        vsp = 0;
    else
        vsp += grv;

    // Coliziune verticala (nu in idle)
    if (!(iele_phase == "orbit" && iele_state == "idle"))
    {
        if (place_meeting(x, y + vsp, oWall))
        {
            while (!place_meeting(x, y + sign(vsp), oWall))
                y += sign(vsp);
            vsp = 0;
        }
        else
            y += vsp;
        y = floor(y);
    }

    // Coliziune orizontala — la perete incearca salt, altfel oprire.
    // EXCEPTIE: "traverse" (dash), "walk" si "skip" NU coliziona cu peretele —
    // toate 3 sunt miscari cu tinta fixa (oprite separat in switch-ul de mai
    // jos cand abs(x-orbit_target_x)<10/12), nu trebuie sa sara/opreasca la
    // perete. Bug gasit live: Ielele ambientale (walk/skip din
    // _iele_pick_orbit, tinta langa marginea arenei prin Iele_EdgeSafeDist)
    // loveau zidul real inainte sa ajunga la tinta — ramaneau blocate sarind
    // pe loc (vsp=-3.5 repetat, fara progres orizontal, agravat de linia
    // "x += hsp" de mai jos care impingea in perete chiar pe ramura de salt).
    // Cu un zid de inaltimea room-ului (nu o treapta mica), saltul nu reuseste
    // niciodata sa treaca — vizual identic cu "merge pe loc in perete". Daca
    // 2 Iele faceau asta simultan pe ziduri opuse si playerul era destul de
    // aproape de amandoua (sub pragul de wrap-eligibility, 350px), nu erau
    // excluse din bounding-box — camera se intindea sa le incadreze pe
    // amandoua cat stateau blocate, parand ca "se blocheaza toata scena".
    // Acelasi tratament ca la "traverse" (bug anterior, doar pentru dash_to)
    // rezolva si cazul ambiental.
    if (hsp != 0)
    {
        if (iele_state == "traverse" || iele_state == "walk" || iele_state == "skip")
            x += hsp;
        else if (place_meeting(x + hsp, y, oWall))
        {
            if (_on_ground && vsp == 0 && iele_phase == "orbit")
                vsp = -3.5; // sare peste perete
            else
            {
                while (!place_meeting(x + sign(hsp), y, oWall))
                    x += sign(hsp);
                hsp = 0;
                if (iele_phase == "orbit")
                {
                    iele_state       = "idle";
                    orbit_move_timer = irandom_range(40, 80);
                }
            }
            x += hsp;
        }
        else
            x += hsp;
    }

    // Scale consistent
    image_yscale = image_yscale_base;

    // ── TIMER PERSONAL — decide cand sa dea rush ──────────────
    if (iele_phase == "orbit")
    {
        personal_timer--;
        if (personal_timer <= 0)
        {
            if (random(1) < 0.65)
            {
                // Continua show-ul
                personal_timer = irandom_range(200, 400);
            }
            else
            {
                // Rush doar daca nicio alta Iela nu face deja rush si nu e atac activ
                var _can_rush = (_cmd == "wander");
                if (_can_rush && _ctrl)
                {
                    for (var _ri = 0; _ri < 3; _ri++)
                    {
                        var _ro = oBoss3Controller.iele[_ri];
                        if (_ro != id && instance_exists(_ro) && _ro.iele_phase == "rush")
                        { _can_rush = false; break; }
                    }
                }
                if (_can_rush)
                {
                    iele_phase = "rush";
                    rush_phase = 0;
                    rush_timer = 0;
                }
                else
                    personal_timer = irandom_range(120, 200); // incearca mai tarziu
            }
        }
    }

    // ── CITESTE ROL DIN SCENARIU (controller) ────────────────────
    if (_ctrl && iele_phase == "orbit")
    {
        var _role = oBoss3Controller.scenario_role[my_index];

        // Detecteaza schimbarea rolului → tranzitioneaza starea
        if (_role != prev_scenario_role)
        {
            prev_scenario_role = _role;
            var _tgt = oBoss3Controller.scenario_target_x[my_index];

            switch (_role)
            {
                case "idle":
                    hsp              = 0;
                    iele_state       = "idle";
                    orbit_move_timer = 9999; // stai idle pana se schimba rolul
                    break;
                case "skip_to":
                    orbit_target_x = _tgt;
                    facing         = (_tgt >= x) ? 1 : -1;
                    iele_state     = "skip";
                    skip_hop_timer = 8;
                    state_timer    = 0;
                    break;
                case "dash_to":
                    orbit_target_x = _tgt;
                    facing         = (_tgt >= x) ? 1 : -1;
                    iele_state     = "traverse";
                    image_index    = 0;
                    image_speed    = 0.2;
                    state_timer    = 0;
                    break;
                case "walk_to":
                    orbit_target_x = _tgt;
                    facing         = (_tgt >= x) ? 1 : -1;
                    iele_state     = "walk";
                    state_timer    = 0;
                    break;
                case "jump":
                    orbit_target_x = _tgt;
                    facing         = (_tgt >= x) ? 1 : -1;
                    iele_state     = "flyover";
                    jump_launched  = false;
                    break;
                case "push":
                    if (iele_phase != "rush")
                    {
                        iele_phase = "rush";
                        rush_phase = 0;
                        rush_timer = 0;
                    }
                    break;

                case "pp_left":
                case "pp_right":
                    // Setup initial: mergi spre pozitie cu skip
                    orbit_target_x = oBoss3Controller.scenario_target_x[my_index];
                    facing         = (orbit_target_x >= x) ? 1 : -1;
                    iele_state     = "skip";
                    skip_hop_timer = 8;
                    state_timer    = 0;
                    push_hit       = false;
                    break;
            }
        }

        // Dupa ce termina o miscare din scenariu → idle automat (nu alege altceva)
        if (_role != "idle" && _role != "push"
        &&  (iele_state == "idle" && orbit_move_timer < 9000))
            orbit_move_timer = 9999; // sta in idle pana schimba scenariul rolul
    }

    // Dezactiveaza personal timer rush daca avem rol activ
    if (_ctrl && oBoss3Controller.scenario_role[my_index] != "idle")
        personal_timer = max(personal_timer, 60);

    // ── PING PONG: per-frame (pp_push_now + animatie push) ────────
    if (_ctrl && iele_phase == "orbit")
    {
        var _cur_role = oBoss3Controller.scenario_role[my_index];
        if (_cur_role == "pp_left" || _cur_role == "pp_right")
        {
            var _pp_dir = (_cur_role == "pp_left") ? 1 : -1;

            // Cand a ajuns la pozitie si asteapta → ramai in idle, nu pleca
            if (iele_state == "idle" && sprite_index != spr_push && !pp_push_now)
            {
                orbit_move_timer = 9999;
                image_xscale = (_px >= x) ? -image_xscale_base : image_xscale_base;
            }

            // Semnalul de push a sosit → trece la animatia de push
            if (pp_push_now && sprite_index != spr_push)
            {
                pp_push_now  = false;
                push_dir     = _pp_dir;
                push_hit     = false;
                sprite_index = spr_push;
                image_index  = 0;
                image_speed  = 0.4;
                image_xscale = -push_dir * image_xscale_base;
                iele_state   = "idle"; // opreste miscarea
                hsp          = 0;
            }

            // Executa animatia de push frame by frame
            if (sprite_index == spr_push)
            {
                image_xscale = -push_dir * image_xscale_base;
                hsp          = push_dir * 0.8;

                var _ppw = x + palm_spr_dx * image_xscale;
                var _ppd = instance_exists(oPlayer) ? abs(_ppw - oPlayer.x) : 999;

                if (floor(image_index) > 2 && _ppd < 90 && !push_hit)
                {
                    push_hit = true;
                    if (instance_exists(oPlayer))
                    with (oPlayer)
                    {
                        pushed_dir   = other.push_dir;
                        pushed_timer = 50;
                        hp          -= 1;
                        flash        = 5;
                    }
                    // Semnal controller: playerul a fost impins
                    if (instance_exists(oBoss3Controller))
                        oBoss3Controller.pp_phase = 2;
                }

                if (animation_end())
                {
                    hsp      = 0;
                    push_hit = false;
                    // Revino la idle dupa push
                    sprite_index = spr_idle;
                    image_speed  = 0.12;
                }
            }
        }
    }

    // ── REPULSIE PASIVA: player si celelalte Iele ────────────────
    if (iele_phase == "orbit" && iele_state != "traverse" && iele_state != "flyover")
    {
        // Repulsie fata de player — DOAR in idle, nu in walk/skip. Motiv (bug
        // gasit live — "merge pe loc"): walk/skip au deja o tinta cu scop
        // (ambiental sau de scenariu); daca tinta e spre player si playerul
        // ramane <150px, repulsia (1.5px/frame) lupta cu mersul (0.8-1.2px/
        // frame) in directie opusa → deriva neta foarte lenta, Iela pare sa
        // "mearga pe loc" (animatia ruleaza, corpul aproape nu se misca) pana
        // la timeout-ul de state_timer (~3.6 sec). Excluzand walk/skip de la
        // repulsia de player, mersul cu scop nu mai e contracarat.
        if (instance_exists(oPlayer) && iele_state == "idle" && abs(x - _px) < 150)
            x += sign(x - _px) * 1.5;
        // Repulsie intre Iele — DOAR in idle, la fel ca la repulsia de player
        // de mai sus. Motiv (a doua varianta a bug-ului "merge pe loc", gasita
        // live): daca Iela A e idle (hsp=0) si Iela B merge/skip spre o tinta
        // care trece pe langa A, verificarea veche de "crossing" (directii
        // opuse) nu prindea cazul — sign(0) nu e nici + nici -, deci A "idle"
        // conta mereu ca sa nu se incruciseaza, iar repulsia (1.0px/frame)
        // lupta aproape 1:1 cu mersul lui B (0.8-1.2px/frame) catre A, exact
        // ca la repulsia de player. Fix: repulsia intre Iele se aplica doar
        // cat timp Iela CURENTA e idle — nu mai intra in conflict cu un mers
        // cu scop.
        if (_ctrl && iele_state == "idle")
        {
            for (var _si = 0; _si < 3; _si++)
            {
                var _so = oBoss3Controller.iele[_si];
                if (_so == id || !instance_exists(_so)) continue;
                if (abs(x - _so.x) >= 80) continue;

                x += sign(x - _so.x) * 1.0;
            }
        }

        // Clamp la limitele arenei — fara asta, repulsia de mai sus putea
        // scoate o Iela complet din arena (si din room) daca playerul o
        // tinea lipita de zid (repulsia o impinge tot inainte, fara sa
        // verifice vreodata peretele).
        if (_ctrl)
            x = clamp(x, oBoss3Controller.arena_x1, oBoss3Controller.arena_x2);
    }

    // ── FAZA: ORBIT (show, dezinteresat) ─────────────────────
    if (iele_phase == "orbit")
    {
        orbit_move_timer--;

        switch (iele_state)
        {
            // ── Idle — leviteaza la inaltimea preferata ──────────
            case "idle":
                sprite_index = spr_idle;
                image_speed  = 0.12;
                hsp          = 0;

                // Drift spre inaltimea preferata deasupra solului
                var _ground_scan = y;
                for (var _gs = 0; _gs < 400; _gs += 4)
                {
                    if (place_meeting(x, y + _gs, oWall)) { _ground_scan = y + _gs; break; }
                }
                var _target_idle_y = _ground_scan - preferred_height;
                y = lerp(y, _target_idle_y, 0.04);

                if (instance_exists(oPlayer))
                    image_xscale = (_px >= x) ? -image_xscale_base : image_xscale_base;

                // Timp mai lung pe loc (4-7 sec)
                if (orbit_move_timer <= 0)
                {
                    iele_state       = "pick";
                    orbit_move_timer = irandom_range(240, 420);
                }
                break;

            // ── Pick — alege urmatoarea miscare ──────────────
            case "pick":
                _iele_pick_orbit();
                break;

            // ── Walk — pasi lenti ─────────────────────────────
            case "walk":
                sprite_index = spr_walk;
                image_speed  = 0.13;
                image_xscale = -facing * image_xscale_base;
                hsp          = facing * 0.8;
                state_timer++;

                if (abs(x - orbit_target_x) < 10 || state_timer > 220)
                {
                    hsp              = 0;
                    state_timer      = 0;
                    iele_state       = "idle";
                    orbit_move_timer = irandom_range(120, 250);
                }
                break;

            // ── Skip — topaituri (saritura e in sprite, nu in cod) ──
            case "skip":
                sprite_index = spr_skip;
                image_speed  = 0.15;
                image_xscale = -facing * image_xscale_base;
                hsp          = facing * 1.2;
                state_timer++;

                if (abs(x - orbit_target_x) < 12 || state_timer > 280)
                {
                    hsp              = 0;
                    state_timer      = 0;
                    iele_state       = "idle";
                    orbit_move_timer = irandom_range(120, 250);
                }
                break;

            // ── Traverse — zbor rapid prin spatiul playerului ─
            case "traverse":
                if (spr_dash == -1) { iele_state = "pick"; break; }
                sprite_index = spr_dash;
                image_speed  = 0.2;
                image_xscale = -facing * image_xscale_base;
                hsp          = facing * 3.5;
                // vsp NE-FORTAT → gravitatia creeaza arc natural

                var _tot  = sprite_get_number(spr_dash);
                var _ls   = max(0, _tot - 5);
                var _le   = max(1, _tot - 2);
                if (floor(image_index) >= _le && abs(x - orbit_target_x) > 24)
                    image_index = _ls;

                if (abs(x - orbit_target_x) < 10)
                {
                    hsp              = 0;
                    iele_state       = "idle";
                    orbit_move_timer = irandom_range(60, 120);
                }
                break;

            // ── Flyover — sare PESTE player cu bolta inalta ──
            case "flyover":
                sprite_index = spr_jump;
                image_speed  = 0.15;
                image_xscale = -facing * image_xscale_base;

                if (!jump_launched && _on_ground)
                {
                    vsp           = -5.5; // bolta inalta
                    hsp           = facing * 1.0;
                    jump_launched = true;
                }
                if (jump_launched && _on_ground && vsp == 0)
                {
                    hsp              = 0;
                    jump_launched    = false;
                    iele_state       = "idle";
                    orbit_move_timer = irandom_range(120, 250);
                }
                break;
        }

        // Clamp la limitele arenei — necesar mai ales pentru "flyover", care
        // deriveaza orizontal in tot timpul saltului FARA sa verifice
        // vreodata orbit_target_x (doar coliziunea fizica reala cu oWall,
        // care poate fi mult mai departe decat limita logica a arenei) —
        // asta lasa o Iela sa iasa din arena daca sare langa margine.
        if (_ctrl)
            x = clamp(x, oBoss3Controller.arena_x1, oBoss3Controller.arena_x2);
    }

    // ── FAZA: PING PONG ──────────────────────────────────────────
    else if (iele_phase == "pingpong")
    {
        var _role = _ctrl ? oBoss3Controller.iele_role[my_index] : "none";

        switch (_role)
        {
            case "left_pusher":
                // Pozitioneaza-te la stanga playerului
                var _pp_target = _px - 180;
                var _pp_dist   = abs(x - _pp_target);
                facing = (_pp_target >= x) ? 1 : -1;

                if (_pp_dist > 20 && !pp_push_now)
                {
                    // In drum spre pozitie
                    sprite_index = spr_skip;
                    image_speed  = 0.2;
                    image_xscale = -facing * image_xscale_base;
                    hsp          = facing * 2;
                    skip_hop_timer--;
                    if (skip_hop_timer <= 0 && _on_ground) { vsp = -1.5; skip_hop_timer = 35; }
                }
                else if (pp_push_now)
                {
                    // Controller a semnalat: IMPINGE
                    pp_push_now  = false;
                    push_dir     = 1; // impinge spre dreapta
                    rush_phase   = 1;
                    rush_timer   = 0;
                    push_hit     = false;
                    sprite_index = spr_push;
                    image_index  = 0;
                    image_speed  = 0.4;
                    hsp          = 0;
                }
                else
                {
                    // Asteapta in pozitie
                    sprite_index = spr_idle;
                    image_speed  = 0.12;
                    image_xscale = -image_xscale_base; // priveste spre dreapta (spre player)
                    hsp          = 0;
                }

                // Executa push-ul cand e semnalizat
                if (rush_phase == 1)
                {
                    sprite_index  = spr_push;
                    image_xscale  = -image_xscale_base;
                    hsp           = push_dir * 1;

                    // Detectie bazata pe pozitia palmei in world
                    var _palm_wx = x + palm_spr_dx * image_xscale;
                    var _palm_wy = y + palm_spr_dy * image_yscale;
                    var _palm_dist = instance_exists(oPlayer) ? abs(_palm_wx - oPlayer.x) : 999; // x-only
                    if (floor(image_index) > 2 && _palm_dist < 90 && !push_hit)
                    {
                        push_hit = true;
                        if (instance_exists(oPlayer))
                        with (oPlayer) { pushed_dir = other.push_dir; pushed_timer = 35; hp -= 1; flash = 5; hitfrom = (other.push_dir > 0) ? 0 : 180; }
                    }
                    if (animation_end())
                    {
                        rush_phase = 0;
                        hsp        = 0;
                    }
                }
                break;

            case "right_pusher":
                var _pp_target_r = _px + 180;
                var _pp_dist_r   = abs(x - _pp_target_r);
                facing = (_pp_target_r >= x) ? 1 : -1;

                if (_pp_dist_r > 20 && !pp_push_now)
                {
                    sprite_index = spr_skip;
                    image_speed  = 0.2;
                    image_xscale = -facing * image_xscale_base;
                    hsp          = facing * 2;
                    skip_hop_timer--;
                    if (skip_hop_timer <= 0 && _on_ground) { vsp = -1.5; skip_hop_timer = 35; }
                }
                else if (pp_push_now)
                {
                    pp_push_now  = false;
                    push_dir     = -1; // impinge spre stanga
                    rush_phase   = 1;
                    rush_timer   = 0;
                    push_hit     = false;
                    sprite_index = spr_push;
                    image_index  = 0;
                    image_speed  = 0.4;
                    hsp          = 0;
                }
                else
                {
                    sprite_index = spr_idle;
                    image_speed  = 0.12;
                    image_xscale = image_xscale_base; // priveste spre stanga (spre player)
                    hsp          = 0;
                }

                if (rush_phase == 1)
                {
                    sprite_index  = spr_push;
                    image_xscale  = image_xscale_base;
                    hsp           = push_dir * 1;

                    // Detectie bazata pe pozitia palmei in world
                    var _palm_wx = x + palm_spr_dx * image_xscale;
                    var _palm_wy = y + palm_spr_dy * image_yscale;
                    var _palm_dist = instance_exists(oPlayer) ? abs(_palm_wx - oPlayer.x) : 999; // x-only
                    if (floor(image_index) > 2 && _palm_dist < 90 && !push_hit)
                    {
                        push_hit = true;
                        if (instance_exists(oPlayer))
                        with (oPlayer) { pushed_dir = other.push_dir; pushed_timer = 35; hp -= 1; flash = 5; hitfrom = (other.push_dir > 0) ? 0 : 180; }
                    }
                    if (animation_end())
                    {
                        rush_phase = 0;
                        hsp        = 0;
                    }
                }
                break;

            case "watch":
                // Se opreste, priveste actiunea
                hsp          = 0;
                sprite_index = spr_idle;
                image_speed  = 0.12;
                if (instance_exists(oPlayer))
                    image_xscale = (_px >= x) ? -image_xscale_base : image_xscale_base;
                break;
        }
    }

    // ── FAZA: RUSH → PUSH → FLEE ─────────────────────────────
    else if (iele_phase == "rush")
    {
        rush_timer++;

        switch (rush_phase)
        {
            // 0: Alearga spre player ──────────────────────────
            case 0:
                var _spd_spr = (spr_dash != -1) ? spr_dash : spr_skip;
                sprite_index = _spd_spr;
                image_speed  = 0.25;
                var _dir0    = (x < _px) ? 1 : -1;
                image_xscale = -_dir0 * image_xscale_base;
                hsp          = _dir0 * 4.5;
                // gravitatie activa → arc

                // A ajuns langa player sau timeout
                if (abs(x - _px) < 75 || rush_timer > 150)
                {
                    rush_phase = 1;
                    rush_timer = 0;
                    hsp        = 0;
                    push_dir   = (x < _px) ? 1 : -1;
                    sprite_index = spr_push;
                    image_index  = 0;
                    image_speed  = 0.4;
                }
                break;

            // 1: Push/impact ──────────────────────────────────
            case 1:
                sprite_index = spr_push;
                image_xscale = -push_dir * image_xscale_base;
                hsp = push_dir * 1.5;

                // Detectie bazata pe pozitia palmei in world
                    var _palm_wx = x + palm_spr_dx * image_xscale;
                    var _palm_wy = y + palm_spr_dy * image_yscale;
                    var _palm_dist = instance_exists(oPlayer) ? abs(_palm_wx - oPlayer.x) : 999; // x-only
                    if (floor(image_index) > 2 && _palm_dist < 90 && !push_hit)
                {
                    push_hit = true;
                    if (instance_exists(oPlayer))
                    with (oPlayer)
                    {
                        pushed_dir   = other.push_dir;
                        pushed_timer = 35;
                        hp     -= 1;
                        flash   = 5;
                        hitfrom = (other.push_dir > 0) ? 0 : 180;
                    }
                }

                if (animation_end())
                {
                    rush_phase = 2;
                    rush_timer = 0;
                    flee_dir   = -push_dir;
                    push_hit   = false;
                    hsp        = 0;
                }
                break;

            // 2: Fuga ─────────────────────────────────────────
            case 2:
                var _flee_spr = (spr_dash != -1) ? spr_dash : spr_skip;
                sprite_index = _flee_spr;
                image_speed  = 0.2;
                image_xscale = -flee_dir * image_xscale_base;
                hsp          = flee_dir * 3.5;

                if (abs(x - _px) > 230 || rush_timer > 100)
                {
                    hsp            = 0;
                    iele_phase     = "orbit";
                    iele_state     = "idle";
                    orbit_move_timer = irandom_range(60, 120);
                    personal_timer = irandom_range(220, 420);

                    if (_ctrl)
                    {
                        oBoss3Controller.command = "wander";
                        oBoss3Controller.cd_push = irandom_range(240, 360);
                    }
                }
                break;
        }
    }
}

// ── HELPER: alege miscarea urmatoare in orbit ─────────────────
function _iele_pick_orbit()
{
    var _ctrl = instance_exists(oBoss3Controller);
    var _ax1  = _ctrl ? oBoss3Controller.arena_x1 : 80;
    var _ax2  = _ctrl ? oBoss3Controller.arena_x2 : (room_width - 80);
    var _px   = instance_exists(oPlayer) ? oPlayer.x : (_ax1 + _ax2) * 0.5;

    var _roll = irandom(99);

    if (_roll < 45 && spr_dash != -1)
    {
        // TRAVERSE (45%): zbor prin spatiul playerului
        var _side    = (x < _px) ? 1 : -1;
        orbit_target_x = clamp(_px + _side * irandom_range(140, 260), _ax1, _ax2);
        iele_state   = "traverse";
        image_index  = 0;
    }
    else if (_roll < 75)
    {
        // FLYOVER (30%): sare deasupra playerului
        var _side    = (x < _px) ? 1 : -1;
        orbit_target_x = clamp(_px + _side * irandom_range(100, 200), _ax1, _ax2);
        iele_state   = "flyover";
        jump_launched = false;
    }
    else if (_roll < 90)
    {
        // SKIP (15%): topaituri — pe aceeasi parte ca Iela fata de player.
        // Distanta se comprima daca ar trece de zid (Iele_EdgeSafeDist) —
        // altfel putea sta lipita de zid langa player pentru cateva secunde.
        var _sign_s    = (x < _px) ? -1 : 1;
        orbit_target_x = _px + _sign_s * Iele_EdgeSafeDist(_px, _sign_s, irandom_range(200, 380), _ax1, _ax2);
        iele_state     = "skip";
        skip_hop_timer = 12;
    }
    else
    {
        // WALK (10%): pasi lenti — pe aceeasi parte ca Iela fata de player.
        // Aceeasi comprimare ca la SKIP.
        var _sign_w    = (x < _px) ? -1 : 1;
        orbit_target_x = _px + _sign_w * Iele_EdgeSafeDist(_px, _sign_w, irandom_range(180, 320), _ax1, _ax2);
        iele_state     = "walk";
    }

    facing = (orbit_target_x >= x) ? 1 : -1;
    target_x = orbit_target_x;
}
