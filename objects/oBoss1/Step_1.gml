// Tranziție DIZZY la HP <= 50% (era "hp == 1", valabil doar cat timp max_hp era 2 de test)
if (hp <= max_hp * 0.5 && state != "dizzy" && state != "dying" && state != "grave")
{
    state = "dizzy";
    sprite_index = sBossDizz;
    image_index = 0;
    image_speed = 0.1;
    hsp = 0;
    attack_cooldown = 99999;
    phase = 2;
}

// Tranziție DYING la HP 0
if (hp <= 0 && state != "dying" && state != "grave")
{
    state = "dying";
    sprite_index = sBoss1D;
    image_index = 0;
    image_speed = 0.13;
    hsp = 0;
}
