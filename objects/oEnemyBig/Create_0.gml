/// @description Inițializare Wolf - mai mare și mai lent

event_inherited(); // Moștenește proprietățile de la oEnemy

// Wolf-ul se mișcă puțin mai lent decât oEnemy normal
walksp = 0.75; // Puțin mai lent (oEnemy are 1)
hsp = walksp;

// Lup mare: verificare margine (labe) — folosit de Enemy_HorizontalResolve
check_distance = 60;

// Wolf este mare vizual dar trebuie bbox mai mic pentru coliziuni
mask_index = sWolfR;
wolf_draw_oy = 0;
wolf_jump_active = false;
wolf_jump_dir    = 0;

sight_range            = 500;
attack_range           = 200;
attack_cooldown_frames = 20;

has_been_hit   = false; // daca a luat damage vreodata → nu mai doarme niciodata
wolf_just_turned = false; // setat de _Enemy_HorizontalResolve la fiecare intoarcere

// Vizual — Enemy_UpdateFacing folosește size
if (object_index == oEnemyBig)
	size = 4;
