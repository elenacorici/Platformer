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

// Lock camera (boss rooms) — activat de oBossCamTrigger
cam_locked = false;
cam_lock_x = 0;
cam_lock_y = 0;
cam_lock_w = 1024;
cam_lock_h = 768;

// Fixeaza scale-ul backgroundurilor parallax la dimensiunile originale (room 1024h)
// astfel incat extinderea camerei in jos sa nu distorsioneze vizual
var _xs = 2048 / 500;
var _ys = 1024 / 192;
var _pars = ["Par1", "Par2"];
for (var _i = 0; _i < array_length(_pars); _i++) {
    if (!layer_exists(_pars[_i])) continue;
    var _lid = layer_get_id(_pars[_i]);
    var _bid = layer_background_get_id(_lid);
    if (room == BossRoom2) {
        var _xs_boss = 4.0;   // cat de lat — ajusteaza
        var _ys_boss = 4;   // cat de inalt — ajusteaza (mai mic = mai scund)
        var _y_boss  = 50;   // offset Y ca sa aliniezi podeaua — ajusteaza (mai mare = mai jos)
        layer_background_stretch(_bid, false);
        layer_background_xscale(_bid, _xs_boss);
        layer_background_yscale(_bid, _ys_boss);
        layer_y(_lid, _y_boss);
    } else if (room == BossRoom_1) {
        // Aceeasi formula ca la rRoom3 (view - podea + extra) — sBackBoss1/2 sunt 500x192,
        // acelasi room height (1024) ca rRoom3, deci acelasi offset de podea (160) e valabil
        var _xs_b1 = 1280.0 / 500.0;                // 2.56 — un tile = exact 1 view width
        var _ys_b1 = (720.0 - 160.0 + 48.0) / 192.0; // 3.17 — view - podea + 48px extra
        layer_background_stretch(_bid, false);
        layer_background_xscale(_bid, _xs_b1);
        layer_background_yscale(_bid, _ys_b1);
    } else {
        // Alte camere: valorile originale neschimbate
        layer_background_xscale(_bid, _xs);
        layer_background_yscale(_bid, _ys);
    }
}

// rTunnel_1 / rTunnel_2 — sBranches 320x320, stretch=false, scale explicit
if (room == rTunnel_1 || room == rTunnel_2)
{
    if (layer_exists("Background"))
    {
        var _lid_t = layer_get_id("Background");
        var _bid_t = layer_background_get_id(_lid_t);
        layer_background_stretch(_bid_t, false);
        layer_background_xscale(_bid_t, 1280.0 / 320.0); // 4.0 — un tile umple view-ul
        layer_background_yscale(_bid_t, 560.0  / 320.0); // 1.75 — acopera zona de deasupra podelei
    }
}

// rRoom3 — scale Par1/Par2/Par3 la 560px inaltime (view 720 - podea 160)
if (room == rRoom3)
{
    var _pars_r3   = ["Par1", "Par2", "Par3"];
    var _yscale_r3 = (720.0 - 160.0 + 48.0) / 300.0; // 2.03 — view - podea + 48px extra
    var _xscale_r3 = 1280.0 / 500.0;                  // 2.56 — un tile = exact 1 view width
    for (var _j = 0; _j < array_length(_pars_r3); _j++)
    {
        var _ln = _pars_r3[_j];
        if (!layer_exists(_ln)) continue;
        var _lid_r3 = layer_get_id(_ln);
        var _bid_r3 = layer_background_get_id(_lid_r3);
        layer_background_stretch(_bid_r3, false);
        layer_background_xscale(_bid_r3, _xscale_r3);
        layer_background_yscale(_bid_r3, _yscale_r3);
    }
}
