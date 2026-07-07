// ── Sprite-uri (Ielă 1 are set complet) ───────────────────
spr_idle   = sIele1Idle;
spr_walk   = sIele1Walk;
spr_skip   = sIele1Skip;
spr_static = sIele1;
spr_dash = sIele1Dash;
spr_jump = sIele1Jump;
spr_push = sIele1Push;
spr_hora    = sHora;
spr_stomp      = sIele1Stomp;
stomp_delay      = 0;
stomp_wait       = 0;
stomp_started    = false;
stomp_loop_frame   = 9;
stomp_impact_frame = 6;
stomp_looping      = false;
stomp_impact_done  = false;
stomp_start_at     = 0;
spr_sit        = sIele1Sit;
spr_sit_hit    = sIele1SitHit;
spr_projectile = PrIele1;
throw_active   = false;
throw_timer    = 0;
throw_fired    = false;
throw_cooldown = 180;

// ── Scale ──────────────────────────────────────────────────
image_xscale_base = 2.8;
image_yscale_base = 1.7;
image_xscale = image_xscale_base;
image_yscale = image_yscale_base;


// ── Fizica ─────────────────────────────────────────────────
hsp = 0;
vsp = 0;
grv = 0.15;
facing = 1;

// ── State machine ─────────────────────────────────────────
iele_state    = "idle";
target_x      = x;
target_y      = y;
idle_timer    = irandom_range(30, 60);

// Locomotion helpers
skip_hop_timer = 0;
jump_launched  = false;
bob_offset     = random(pi * 2);

// ── Push ──────────────────────────────────────────────────
push_can   = false;
push_hit   = false;
push_dir   = 1;
push_timer = 0;

// ── Inregistrare in controller ─────────────────────────────
if (instance_exists(oBoss3Controller))
    oBoss3Controller.iele[0] = id;

// ── Timer system (desincronizat per Iela) ─────────────────────
iele_phase       = "orbit";
personal_timer   = irandom_range(120, 360); // diferit per Iela
orbit_move_timer = irandom_range(60, 180);
orbit_target_x   = x;
rush_phase       = 0;
rush_timer       = 0;
flee_dir         = 1;

// ── Identitate si rol in atacuri coordonate ───────────────────
my_index     = 0;
iele_role    = "none";
pp_push_now   = false; // semnal de la controller: impinge acum
pp_has_pushed = false; // dupa push, nu se mai misa
state_timer = 0;
preferred_height = 0;   // Iela 1 — aproape de sol
prev_scenario_role = "none";
palm_spr_dx = -35; // offset palma de la xorigin in sprite (sIele1Push)
palm_spr_dy = -40;
iele_attack = "none"; // none | pp_left | pp_right | pp_watch
pp_charging = false;
pp_hit_stop = 0;

// ── HP ────────────────────────────────────────────────────
// ── Intro bounce system ───────────────────────────────
spr_idle_still   = sIele1IdleStill;
intro_walk_phase = "pre";   // "pre" | "patrol" | "walk" | "wait"
intro_bounces    = 0;
intro_at_wall    = false;
intro_pat_dir    = 1;
intro_center_offset = -32;
hp               = 6;
hp_max           = 6;
invincible_timer = 0;
flash            = 0;
hitfrom          = 0;
is_dead          = false;
rage_active      = false;
