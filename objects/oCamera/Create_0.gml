/// @description initializare camera

cam = view_camera[0];
follow = oPlayer;

// Rezolutie interna: 1280x720 (16:9), scalata la fullscreen
var _view_w = 1280;
var _view_h = 720;
camera_set_view_size(cam, _view_w, _view_h);
surface_resize(application_surface, _view_w, _view_h);
display_set_gui_size(_view_w, _view_h);

view_w_half = _view_w * 0.5;
view_h_half = _view_h * 0.5;
xTo = xstart;
yTo = ystart;

shake_length    = 0;
shake_magnitude = 0;
shake_remain    = 0;
buff = 32;

// Porneste fullscreen, F4 toggle
window_set_fullscreen(true);

// Letterbox pentru tunel
letterbox_current = 0;   // pixels tăiați sus și jos (0 = nimic)
letterbox_target  = 0;
letterbox_max     = 200; // cât de mult se îngustează — ajustează după gust

hora_surf = -1; // surface pentru efectul de vignette hora
cam_y_offset = 0;

// Fixeaza scale-ul backgroundurilor parallax la dimensiunile originale (room 1024h)
// astfel incat extinderea camerei in jos sa nu distorsioneze vizual
var _xs = 2048 / 500;
var _ys = 1024 / 192;
var _pars = ["Par1", "Par2"];
for (var _i = 0; _i < array_length(_pars); _i++) {
    if (layer_exists(_pars[_i])) {
        var _bid = layer_background_get_id(layer_get_id(_pars[_i]));
        layer_background_xscale(_bid, _xs);
        layer_background_yscale(_bid, _ys);
    }
}
