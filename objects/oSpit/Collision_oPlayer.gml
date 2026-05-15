if (hit) exit;

// Damage player
with (other)
{
    hp--;
    hp    = max(0, hp);
    flash = 3;
}

// Pornește animația de impact
hspeed = 0;
vspeed = 0;
hit    = true;
sprite_index = spitP2;
image_index  = 0;
image_speed  = 0.2;
