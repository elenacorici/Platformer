depth = 580; // în fața Player(600)
boss_layer = layer; // salvat pentru scripturi
hp = 100;
max_hp = 100;
flash = 0;
hitfrom = 0;

state = "idle";
idle_image_speed = 0.2;

boss_scale = 2.5;
facing = 1;

hsp = 0;
vsp = 0;
grv = 0.1;

mask_index = sBoss1;

// Phase system
phase = 1; // 1 = normal, 2 = HP < 50%

// Cooldown-uri atacuri
attack_cooldown  = 120;
hop_cooldown     = 0;
ivy_cooldown     = 0;
slam_cooldown    = 0;
slam_recover_timer = 0;
slam_hit_list    = ds_list_create();

// Attack tracking
attack_ivy_inst1 = noone;
attack_ivy_inst2 = noone;
prev_image_index = 0;
hop_recover_timer = 0;

// Particule impact/decolare
p_sys = part_system_create_layer(layer, false);
part_system_depth(p_sys, -100); // în fața tuturor
p_dirt = part_type_create();
part_type_shape(p_dirt, pt_shape_pixel);
part_type_size(p_dirt, 4, 9, -0.1, 0);
part_type_colour3(p_dirt, make_colour_rgb(100, 50, 15), make_colour_rgb(70, 35, 10), make_colour_rgb(40, 20, 5)); // maro închis → maro deschis
part_type_alpha2(p_dirt, 1, 0);
part_type_speed(p_dirt, 2, 6, -0.15, 0);
part_type_direction(p_dirt, 60, 120, 0, 20); // în sus, ușor lateral
part_type_gravity(p_dirt, 0.3, 270);
part_type_life(p_dirt, 20, 40);

// Patrol
patrol_origin = x;       // centrul patrulei
patrol_range = 190;        // distanță max față de origin
patrol_speed = 1;
patrol_dir = 1;           // 1 = dreapta, -1 = stânga
patrol_idle_timer = 60; // pauză inițială înainte de primul patrol
patrol_idle_duration = 90; // frames de pauză între ture
