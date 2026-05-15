// Dizzy la penultima lovitură (1 HP rămas)
if (hp == 1 && state != "dizzy" && state != "dying" && state != "grave")
{
    state        = "dizzy";
    sprite_index = sBoss2Dizzy;
    image_index  = 0;
    image_speed  = 0.12;
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
    hsp          = 0;
}
