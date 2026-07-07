x += proj_spd_x;
y += proj_spd_y;

// Hit player
if (instance_exists(oPlayer) && place_meeting(x, y, oPlayer))
{
    with (oPlayer)
    {
        hp    -= other.proj_damage;
        flash  = 8;
    }
    instance_destroy();
    exit;
}

// Hit wall
if (place_meeting(x, y, oWall))
{
    instance_destroy();
    exit;
}

// Lifetime
lifetime--;
if (lifetime <= 0) instance_destroy();
