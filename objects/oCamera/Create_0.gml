/// @description initializare camera

cam= view_camera[0];
follow = oPlayer;
view_w_half = camera_get_view_width(cam) * 0.5;
view_h_half = camera_get_view_height(cam) * 0.5;
xTo = xstart;
yTo= ystart;

shake_length=0;
shake_magnitude=0;
shake_remain=0;
buff=32;

// Letterbox pentru tunel
letterbox_current = 0;   // pixels tăiați sus și jos (0 = nimic)
letterbox_target  = 0;
letterbox_max     = 200; // cât de mult se îngustează — ajustează după gust
