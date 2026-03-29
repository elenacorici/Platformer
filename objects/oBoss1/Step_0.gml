vsp += grv;
Enemy_VerticalResolve();

// Se întoarce spre player doar în atac
if (instance_exists(oPlayer) && state != "patrol" && state != "idle" && state != "patrol_idle") {
    var _dir = sign(oPlayer.x - x);
    if (_dir != 0) facing = -_dir;
}

image_xscale = facing * boss_scale;
image_yscale = boss_scale;

// ── COOLDOWN-URI ────────────────────────────────
if (attack_cooldown > 0) attack_cooldown--;
if (hop_cooldown    > 0) hop_cooldown--;
if (ivy_cooldown    > 0) ivy_cooldown--;
if (slam_cooldown   > 0) slam_cooldown--;

// ── TEST INPUT (temporar) ───────────────────────
if (keyboard_check_pressed(ord("U"))) {
    state = "patrol";
    sprite_index = sBoss1W;
    image_index = 0;
    image_speed = 0.15;
    patrol_origin = x;
}
else if (keyboard_check_pressed(ord("Y"))) {
    state = "attack_hop_windup";
    sprite_index = sBoss1J;
    image_index = 0;
    prev_image_index = 0;
    image_speed = 0.3;
    hsp = 0;
}
else if (keyboard_check_pressed(ord("T"))) {
    state = "attack_ivy";
    sprite_index = sBossA1;
    image_index = 0;
    prev_image_index = 0;
    image_speed = 0.15;
}

// ── DECIZIE AUTOMATĂ ────────────────────────────
if (state == "idle" && attack_cooldown <= 0) {
    Boss1_DecideAction();
}

// ── STATE MACHINE ───────────────────────────────
if (state == "idle") {
    sprite_index = sBoss1I;
    image_speed = idle_image_speed;
}

Boss1_Phase1_Patrol();
Boss1_Phase2_Hop();
Boss1_Phase3_Ivy();
Boss1_Phase4_Slam();

prev_image_index = image_index;
