// ── Vignette hora (controle inversate) ───────────────────────
if (instance_exists(oPlayer) && oPlayer.controls_inverted)
{
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _t  = oPlayer.invert_timer / 240;  // 1=inceput, 0=sfarsit

    // Pozitia playerului in spatiul GUI
    var _cam_x = camera_get_view_x(cam);
    var _cam_y = camera_get_view_y(cam);
    var _cx    = (oPlayer.x - _cam_x) / 1280 * _gw;
    var _cy    = (oPlayer.y - _cam_y) / 720  * _gh;

    // Raza pulsatorie
    var _pulse  = sin(current_time / 260.0) * 28;
    var _radius = 200 + _pulse;

    // Surface: gradient radial — intunecat la margini, transparent langa player
    if (!surface_exists(hora_surf))
        hora_surf = surface_create(_gw, _gh);

    var _layers = 18;
    var _r_out  = 580;        // raza exterioara (marginile ecranului)
    var _r_in   = _radius;    // raza interioara (langa player) — pulsatorie

    surface_set_target(hora_surf);
        draw_clear_alpha(c_black, 1);
        gpu_set_blendmode(bm_subtract);
        draw_set_color(c_white);
        for (var _i = 0; _i < _layers; _i++)
        {
            var _r = lerp(_r_out, _r_in, _i / (_layers - 1));
            draw_set_alpha(1.0 / _layers);
            draw_circle(_cx, _cy, _r, false);
        }
        gpu_set_blendmode(bm_normal);
    surface_reset_target();

    draw_set_alpha(_t * 0.88);
    draw_surface(hora_surf, 0, 0);
    draw_set_alpha(1);
}

// Bare laterale pentru camere înguste (rTunnel / rTunnel_1 = 1024px wide, view = 1280px)
if (room == rTunnel || room == rTunnel_1)
{
    var _gw  = display_get_gui_width();
    var _gh  = display_get_gui_height();
    var _bar = round((_gw - room_width) * 0.5); // 128px
    draw_set_color(c_black);
    draw_set_alpha(1);
    draw_rectangle(0,        0, _bar,      _gh, false);
    draw_rectangle(_gw - _bar, 0, _gw,    _gh, false);
    draw_set_alpha(1);
}

// Letterbox bars — desenate pe GUI deci nu sunt afectate de cameră
var _bar = round(letterbox_current);
if (_bar > 0)
{
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    draw_set_color(c_black);
    draw_set_alpha(1);
    draw_rectangle(0, 0, _gw, _bar * 1.4, false);         // bara de sus (mai mare)
    draw_rectangle(0, _gh - _bar * 0.6, _gw, _gh, false); // bara de jos (mai mică)
    draw_set_alpha(1);
}
