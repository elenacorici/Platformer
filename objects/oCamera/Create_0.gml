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
