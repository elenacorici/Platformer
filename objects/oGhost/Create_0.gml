event_inherited(); // preia variabilele de baza din oEnemy (hp, hitPlayerThisAttack, ENEMYSTATE, etc.)

grv             = 0;       // fantoma nu cade
grounded        = false;
afraidOfHeights = false;

sight_range           = 220;
attack_range          = 30;
move_speed            = 1.8;
patrol_move_speed     = 0.6;
attack_cooldown_frames = 70;
size                  = 2;

mask_index       = sGhostIdle;

float_y_base    = y + 45;         // pozitia Y de echilibru (spawn)
float_time      = irandom(1800);  // faza initiala random
float_amplitude = 14;             // amplitudine plutire sus-jos (px)
patrol_range_x  = 90;             // dist. max de la xstart in patrula
post_attack_timer = 0;
post_attack_drift = 0;
dying             = false;
