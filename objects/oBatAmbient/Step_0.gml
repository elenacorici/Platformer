// Liliac care zboară — creat de controller cu hspeed setat
if (hspeed != 0)
{
    image_xscale = (hspeed < 0) ? -2 : 2;
    var _cam_x = camera_get_view_x(view_camera[0]);
    var _cam_w = camera_get_view_width(view_camera[0]);
    if (x < _cam_x - 80 || x > _cam_x + _cam_w + 80)
        instance_destroy();
    exit;
}

// Controller invizibil — plasat manual in room
visible = false;
flock_timer--;
if (flock_timer <= 0)
{
    flock_timer   = irandom_range(400, 900);
    flock_pending = irandom_range(5, 12);
    flock_delay   = 0;
    flock_dir     = choose(-1, 1);
}

if (flock_pending > 0)
{
    flock_delay--;
    if (flock_delay <= 0)
    {
        flock_delay   = irandom_range(4, 10);
        flock_pending--;
        var _cam_x = camera_get_view_x(view_camera[0]);
        var _cam_y = camera_get_view_y(view_camera[0]);
        var _cam_w = camera_get_view_width(view_camera[0]);
        var _bx = (flock_dir > 0) ? _cam_x - 48 : _cam_x + _cam_w + 48;
        var _by = _cam_y + y_offset + irandom_range(16, 140);
        var _b  = instance_create_depth(_bx, _by, -900, oBatAmbient);
        _b.hspeed = flock_dir * (3 + random(2.5));
    }
}
