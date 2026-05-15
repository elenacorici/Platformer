// Tranziție DIZZY la ultimul HP
if (hp == 1 && state != "dizzy" && state != "dying" && state != "grave")
{
    state = "dizzy";
    sprite_index = sBossDizz;
    image_index = 0;
    image_speed = 0.1;
    hsp = 0;
    attack_cooldown = 99999;
}

// Tranziție DYING la HP 0
if (hp <= 0 && state != "dying" && state != "grave")
{
    state = "dying";
    sprite_index = sBoss1D;
    image_index = 0;
    image_speed = 0.08;
    hsp = 0;
}
