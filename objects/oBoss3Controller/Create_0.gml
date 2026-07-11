// Referinte catre cele 3 Iele (inregistrate de fiecare in Create_0)
iele[0] = noone;
iele[1] = noone;
iele[2] = noone;

// Blackboard — actualizat la fiecare frame
bb_player_x = 0;
bb_player_y = 0;

// Limitele arenei (Ielele nu ies din zona asta) — room-ul a fost redimensionat
// ca sa fie EXACT arena (fara zona moarta), deci fara buffer separat aici;
// marginile de 40px deja folosite in scenarii/edge-safety (Iele_EdgeSafeDist
// etc.) sunt suficiente ca sa nu se lipeasca exact de perete.
arena_x1 = 0;
arena_x2 = room_width;

// Comanda curenta
// "wander" | "push"
command = "wander";

// ── Sistem scenarii ───────────────────────────────────────────
current_scenario  = "";
last_scenario     = "";
scenario_timer    = 120; // delay initial
scenario_phase    = 0;   // sub-faza in scenariile complexe
scenario_phase_t  = 0;   // timer sub-faza

// Roluri + tinte per Iela
scenario_role[0]     = "idle";
scenario_role[1]     = "idle";
scenario_role[2]     = "idle";
scenario_target_x[0] = 0;
scenario_target_x[1] = 0;
scenario_target_x[2] = 0;

// Cooldown push simplu
cd_push = 180;

// Ping Pong
pp_phase     = 0;
pp_timer     = 0;
pp_passes    = 0;
pp_left_idx  = -1;
pp_right_idx = -1;
cd_pingpong  = 360;

// Ping Pong attack state
pp_active        = false;
pp_left_ready    = false;
pp_right_ready   = false;
pp_hit_received  = false;

// Stomp (urlet)
stomp_center_x = 0;

// Perch (creanga)
perch_count = 0; // cate Iele sunt deja pe creanga
perch_x     = 0; // setat la primul apas de I (mijlocul arenei)
perch_y     = 0; // setat la primul apas de I (elevat)

// Hora
hora_active      = false;
hora_phase       = 0; // 0=pozitionare, 1=gata
hora_timer       = 0;
hora_center_x    = 0;

// ── Death tracking ────────────────────────────────────────────
iele1_dead  = false;
iele2_dead  = false;
iele3_dead  = false;
fight_ended = false;

// ── Phase sistem ──────────────────────────────────────────────
boss_phase        = 1;   // 1 / 2 / 3
phase2_triggered  = false;
phase3_triggered  = false;

// Trigger conditions
iele3_far_timer    = 0; // cat timp Iela3 pe creanga + player departe
player_last_x      = 0;
player_last_y      = 0;
player_still_timer = 0;
bow_distance_timer = 0;

// Phase setup flags
phase2_setup_done     = false;
phase3_setup_done     = false;
phase2_iele3_on_perch = false;
phase2_iele3_timer    = 0;

// Selectie atacuri
attack_cd          = 900;  // 15 sec pana la primul atac combinat
cd_hora            = 900;  // 15 sec delay initial
cd_stomp           = 9999; // blocat in phase 1 si 2
hora_preview_done  = false;
phase1_setup_done  = false;
phase1_perch_timer = 300;  // 5 sec pana cand Iela3 urca pe creanga
hora_dispersal_done = false; // true dupa prima hora reala (2, prima de atac) — vezi _end_hora()

// Post-hora Phase 1: push attack imediat dupa dispersie dramatica
phase1_push_pending = false;
phase1_push_timer   = 0;

// ── Intro ────────────────────────────────────────────────────
fight_started           = false;
intro_triggered         = false; // setat de oIntroTrigger cand player intra in arena
intro_step              = 0;   // 0=wait trigger, 1=patrula+adunare, 2=hora_form, 3=dialog
intro_timer             = 0;
combat_visible          = false; // true dupa ce hora #2 (atacul de start) se termina si Ielele se
                                  // imprastie dramatic — abia atunci apare Health bar-ul in Draw_64
intro_arena_timer       = 0;
intro_sync_dur          = 150; // durata sincronizata a cursei spre hora (calculata la start)
intro_dialog_visible    = false;
intro_vignette_active   = false; // true din step 3 pana la sfarsitul primei hore
intro_vignette_timer    = 0;     // timer backup — se decrementeaza in Draw_64
intro_target_x          = array_create(3, 0);

// Stomp + ploaie bolovani
stomp_active      = false;
stomp_rain_active = false;
stomp_rain_timer  = 0;
stomp_rain_cd     = 0;
stomp_rain_dur    = 360; // 6 sec de ploaie
stomp_sync_started = false;
stomp_sync_timer   = -1;
stomp_shake_at     = -1;
