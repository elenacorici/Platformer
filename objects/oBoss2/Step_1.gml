// Dizzy când hp ajunge la 1 sau mai puțin (inclusiv combo 2 damage)
if (hp <= 1 && state != "dizzy" && state != "dying" && state != "grave")
{
    hp           = 1; // forțează 1 HP — dying nu se declanșează încă
    state        = "dizzy";
    sprite_index = sBoss2Dizzy;
    image_index  = 0;
    image_speed  = 0.25;
    hsp          = 0;
    attack_cooldown = 99999;
}

// Moarte la 0 HP
if (hp <= 0 && state != "dying" && state != "grave")
{
    state        = "dying";
    sprite_index = sBoss2Die;
    image_index  = 0;
    image_speed  = 0.1;
    image_angle  = 0;
    hsp          = 0;
}
