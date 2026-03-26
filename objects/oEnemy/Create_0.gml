/// @description Init (ENEMYSTATE în EnemyState_Definitions)
state = ENEMYSTATE.PATROL;
// După animația de atac revine la CHASE (sau PATROL dacă setezi altceva)
state_after_attack = ENEMYSTATE.CHASE;

move_speed = 2;           // viteză în chase (urmărire)
patrol_move_speed = 0.75; // mult mai încet la patrol (PATROL)
size = 1.3;
patrol_dir = 1;
mask_index = sEnemy;
check_distance = 25;

sight_range = 150;
attack_range = 56;
wall_tile_height = sprite_get_height(sWall);
same_level_slack = 6;

attack_anim_speed = 0.4;
attack_cooldown = 0;
attack_cooldown_frames = 40;

hitPlayerThisAttack = ds_list_create();

idle_break_phase = 0;
idle_break_breath_timer = 0;
idle_break_will_scratch = false;
idle_break_cooldown = 0;
idle_breath_min_frames = 20;
idle_breath_max_frames = 85;
idle_break_cooldown_min = 140;
idle_break_cooldown_max = 380;
idle_edge_extra = 20;
idle_break_roll_chance_ledge = 0.025;
idle_scratch_chance = 0.72;
idle_breath_image_speed = 0.14;
idle_scratch_image_speed = 0.38;
idle_patrol_idle_anim_mult = 0.5;
