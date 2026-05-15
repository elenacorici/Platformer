var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_w = camera_get_view_width(view_camera[0]);

// Iese din ecran în direcția de mers → semnalează boss-ul
var _exited = (wolf_dir < 0 && x < _cam_x - 100)
           || (wolf_dir > 0 && x > _cam_x + _cam_w + 100);

if (_exited)
{
    if (instance_exists(oBoss2))
    {
        oBoss2.wolf_done = true;
        oBoss2.wolf_dir  = wolf_dir; // boss știe pe ce parte să reapară
    }
    instance_destroy();
}
