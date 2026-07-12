/// @description Init oBee — hover ambiental -> chase -> impunge playerul (atac fara stare separata)

image_xscale=2;
image_yscale=2;
state = "patrol";
sprite_index = albinuta_patrol;
image_speed  = 0.25;
depth        = -100; // in fata tileset-ului si wall-urilor, ca oBat

// Masca fixa — cele 3 sprite-uri (albinuta/albinuta_chase/albinuta_patrol) au bbox usor
// diferit intre ele, altfel masca de coliziune s-ar schimba odata cu sprite-ul curent
// (aceeasi problema gasita si fixata la Iele — vezi oBoss31/32/33)
mask_index = albinuta_chase;

// Coliziune cu oWall — dezactivata implicit (0). Se activeaza doar per-instanta,
// suprascriind "collision = 1;" din Instance Creation Code in room editor.
collision = 0;

home_x = x;
home_y = y;

// Hover / patrol ambiental — zboara intre puncte random in jurul home, cu pauze scurte
patrol_radius =100;
hover_speed   = 1.5;
resting       = false;
rest_timer    = 0;

// Zbor organic — wobble sinusoidal perpendicular pe directia de zbor
wobble_timer      = random(1000); // desincronizeaza mai multe albine intre ele
wobble_speed      = 0.09 + random(0.04);
wobble_amp_patrol = 8;
wobble_amp_chase  = 3;

// Detectie player / chase
sight_range   =300;
give_up_range = 500; // > sight_range — histerezis, nu oscileaza intre stari la limita
chase_speed   = 2.6;
turn_speed    = 6;   // grade/frame — cat de repede se roteste spre player in chase
fly_dir       = 0;

// Atac — contact direct in timpul chase-ului, "impunge" cu fata, fara stare/sprite separat
poke_range        = 22;
poke_damage       = 1;
poke_cooldown     = 0;
poke_cooldown_max = 45;

// Moarte — un hit (melee sau sageata) o omoara direct, ca la oBat (fara hp)
dead_timer = 0;

// Primul punct de hover
var _a = random(360);
var _d = random(patrol_radius);
hover_target_x = home_x + lengthdir_x(_d, _a);
hover_target_y = home_y + lengthdir_y(_d, _a);
