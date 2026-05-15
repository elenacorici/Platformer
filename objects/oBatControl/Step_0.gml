if (bat_spawned >= bat_count)
{
    instance_destroy();
    exit;
}

spawn_timer--;
if (spawn_timer > 0) exit;

spawn_timer = spawn_delay;
bat_spawned++;

var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_y = camera_get_view_y(view_camera[0]);
var _cam_w = camera_get_view_width(view_camera[0]);
var _cam_h = camera_get_view_height(view_camera[0]);

var _bx, _by;

if (spawn_side == "right")
{
    // Intră din dreapta, la înălțimi variate
    _bx = _cam_x + _cam_w + 32;
    _by = _cam_y + _cam_h * 0.15 + random(_cam_h * 0.5);
}
else // "top"
{
    // Intră de sus, la poziții orizontale variate
    _bx = _cam_x + _cam_w * 0.2 + random(_cam_w * 0.6);
    _by = _cam_y - 32;
}

instance_create_layer(_bx, _by, "Enemies", oBat);
