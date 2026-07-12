hsp=0;
vsp=0;
grv=0.1;
walksp=4;
hascontrol=true;
is_crouching = false;
was_crouching = false;
hp = 6;
max_hp = 6;
max_hearts = 3;
hp_temp = 6;   // pentru scădere graduală
heart_shake = 0;
chamomile_count = 0;
has_axe = true;  // TODO: pune false cand oAxe e plasat in rOne
has_bow = false;
current_weapon = "axe"; // "axe" sau "bow"
has_opinci       = false;
opinci_state     = "ready";    // "ready", "active", "cooldown"
opinci_timer     = 0;
opinci_boost_sp  = 7;          // viteza cu boost
opinci_active_t  = 300;        // 5 secunde la 60fps
opinci_cooldown_t = 240;       // 4 secunde cooldown

bow_phase        = "draw";
bow_charge_timer = 0;
bow_charge_level = 0;    // 0=fail, 1=normal, 2=full
bow_aim_dir      = 0;
bow_target       = noone;
flash = 0;
hitfrom = 0;
image_xscale=1.30;
image_yscale=1.25;

// Define enum before using it
enum PLAYERSTATE
{
	FREE,
	ATTACK_SLASH,
	ATTACK_COMBO,
	FINISHING_MOVE,
	ATTACK_BOW,
	CLIMBING
}

state=PLAYERSTATE.FREE;
hitByAttack= ds_list_create();

// sPlayer e desenat spre stânga; convenția din cod: față spre dreapta => image_xscale -1
image_xscale = -1;

roll_dir = 1;
roll_timer = 0;
roll_duration = 60;
roll_speed = 5;
roll_anim_timer = 0; // avansul framurilor de roll, controlat manual (nu prin image_speed)
roll_looping = false; // true = in bucla scurta 5↔6, cat timp W e tinut apasat
roll_loop_alt = false; // alterneaza intre frame 5 si 6 in bucla scurta
fast_falling = false;

jumps_max = 2;
jumps_left = 2;

combo_count = 0;
combo_timer = 0;
combo_window = 20;

// Double jump — particule (stratul din cameră: „Player”, nu „Instances”)
p_sys = part_system_create_layer("Player", false);
p_dust = part_type_create();
part_type_shape(p_dust, pt_shape_pixel);
part_type_size(p_dust, 1, 3, -0.1, 0);
part_type_color2(p_dust, c_white, c_ltgray);
part_type_alpha2(p_dust, 1, 0);
part_type_speed(p_dust, 1, 3, -0.1, 0);
part_type_direction(p_dust, 0, 360, 0, 30);
part_type_gravity(p_dust, 0.2, 270);
part_type_life(p_dust, 15, 25);

// Particule rosii — moarte pe spikes (acelasi p_sys, tip nou de particula)
p_hurt = part_type_create();
part_type_shape(p_hurt, pt_shape_pixel);
part_type_size(p_hurt, 2, 4, -0.05, 0);
part_type_color2(p_hurt, c_red, c_maroon);
part_type_alpha2(p_hurt, 1, 0);
part_type_speed(p_hurt, 2, 5, -0.1, 0);
part_type_direction(p_hurt, 0, 360, 0, 30);
part_type_gravity(p_hurt, 0.15, 270);
part_type_life(p_hurt, 25, 40);

// Spikes — blink rosu repetat inainte de restart total (tasta R deja face
// SlideTransition(TRANS_MODE.RESTART) — refolosim exact mecanismul asta)
spike_hit_timer = 0;

is_stunned      = false;
stun_timer      = 0;
knockback_hsp    = 0;
knockback_timer  = 0;
pushed_dir       = 0;   // directia in care e impins (1 sau -1)
pushed_timer     = 0;   // cat timp e in idle impins
post_push_timer  = 0;   // cat timp merge 2 pasi dupa push

// Hora
hora_pull         = false;
hora_pull_x       = 0;
hora_stunned      = false;
hora_stun_timer   = 0;
controls_inverted = false;
invert_timer      = 0;

// Finishing move
fm_phase      = -1;  // -1=inactiv, 0=walk back, 1=P1, 2=P2, 3=freeze
fm_boss       = noone;
fm_prev_frame = 0;
fm_dir        = 1;
fm_target_x   = 0;
climb_lock    = 0;