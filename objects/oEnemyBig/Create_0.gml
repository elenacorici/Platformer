/// @description Inițializare Wolf - mai mare și mai lent

event_inherited(); // Moștenește proprietățile de la oEnemy

// Wolf-ul se mișcă puțin mai lent decât oEnemy normal
walksp = 0.75; // Puțin mai lent (oEnemy are 1)
hsp = walksp;

// Wolf este mare vizual dar trebuie bbox mai mic pentru coliziuni
mask_index = sEnemy; // Folosește bbox-ul de la Enemy pentru coliziuni mai precise
