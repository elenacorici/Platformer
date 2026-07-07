var _prev_x = x;

// Miscare
x += spd * move_dir;

// Intoarce directia la capete
if (x >= x_start + patrol_dist)
{
    x        = x_start + patrol_dist;
    move_dir = -1;
}
else if (x <= x_start)
{
    x        = x_start;
    move_dir = 1;
}

// Carry player: daca playerul sta pe platforma, il misca cu ea
var _dx = x - _prev_x;
if (_dx != 0 && instance_exists(oPlayer)
&&  place_meeting(x, y - 1, oPlayer))
    oPlayer.x += _dx;
