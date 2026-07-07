// ── Sprite-uri (Ielă 2 — fara dash, idle din shared) ──────
spr_idle   = sIele2Idle;
spr_walk   = sIele2Walk;
spr_skip   = sIele2Skip;
spr_static = sIele2;
spr_dash = -1;          // nu are dash → IeleUpdate va folosi skip
spr_jump = sIele2Jump;
spr_push = sIele2Push;
spr_hora    = sHora;
spr_stomp      = sIele2Stomp;
stomp_delay      = 0;
stomp_wait       = 0;
stomp_started    = false;
stomp_loop_frame   = 9;
stomp_impact_frame = 6;
stomp_looping      = false;
stomp_impact_done  = false;
stomp_start_at     = 0;
spr_sit        = sIele2Sit;
spr_sit_hit    = sIele2SitHit;
spr_projectile = PrIele2;
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
idle_timer    = irandom_range(40, 90);

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
    oBoss3Controller.iele[1] = id;

// ── Timer system (desincronizat per Iela) ─────────────────────
iele_phase       = "orbit";
personal_timer   = irandom_range(120, 360); // diferit per Iela
orbit_move_timer = irandom_range(60, 180);
orbit_target_x   = x;
rush_phase       = 0;
rush_timer       = 0;
flee_dir         = 1;

// ── Identitate si rol in atacuri coordonate ───────────────────
my_index     = 1;
iele_role    = "none";
pp_push_now   = false;
pp_has_pushed = false;
state_timer = 0;
preferred_height = 90;  // Iela 2 — medie
prev_scenario_role = "none";
palm_spr_dx = -30;
palm_spr_dy = -39;
iele_attack = "none"; // none | pp_left | pp_right | pp_watch
pp_charging = false;
pp_hit_stop = 0;

// ── HP ────────────────────────────────────────────────────
// ── Intro bounce system ───────────────────────────────
spr_idle_still   = sIele2IdleStill;
intro_walk_phase = "pre";   // "pre" | "patrol" | "walk" | "wait"
intro_bounces    = 0;
intro_at_wall    = false;
intro_pat_dir    = 1;
intro_center_offset = 0;
hp               = 6;
hp_max           = 6;
invincible_timer = 0;
flash            = 0;
hitfrom          = 0;
is_dead          = false;
rage_active      = false;
