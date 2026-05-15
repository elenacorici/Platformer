image_speed  = 0.3;
image_xscale = 2;
image_yscale = 2;
hit = false;

// Direcție fixă spre player — același sistem ca oBullet
if (instance_exists(oPlayer))
{
    direction   = point_direction(x, y, oPlayer.x, oPlayer.y);
    speed       = 7;
    image_angle = direction;
    vspeed     -= 4; // impuls în sus — creează bolta
}
