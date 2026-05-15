depth       = 50;
hp          = 20;
max_hp      = 20;
flash       = 0;
hitfrom     = 0;

state            = "idle";
idle_image_speed = 0.10; // 6 FPS

boss_scale = 2.5;
facing     = 1;

hsp = 0;
vsp = 0;
grv = 0.1;

mask_index = sBoss2;

phase = 1;

// Cooldown-uri atacuri
attack_cooldown = 120;
spit_cooldown   = 0;
bats_cooldown   = 0;
wolf_cooldown   = 0;
last_attack     = "";

// Walk — mers rigid spre player
walk_speed = 1.2;

// Recovery
recover_timer = 0;

// Wolf attack
wolf_done = false;
wolf_dir  = -1;

prev_image_index = 0;

// Particule
p_sys  = part_system_create_layer(layer, false);
part_system_depth(p_sys, -100);
p_dirt = part_type_create();
part_type_shape(p_dirt, pt_shape_pixel);
part_type_size(p_dirt, 2, 6, -0.1, 0);
part_type_colour3(p_dirt, make_colour_rgb(140, 120, 90), make_colour_rgb(90, 70, 50), make_colour_rgb(50, 40, 30));
part_type_alpha2(p_dirt, 1, 0);
part_type_speed(p_dirt, 1, 4, -0.1, 0);
part_type_direction(p_dirt, 60, 120, 0, 20);
part_type_gravity(p_dirt, 0.2, 270);
part_type_life(p_dirt, 20, 35);
