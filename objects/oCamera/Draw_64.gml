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

// Bare laterale pentru camere înguste (rTunnel / rTunnel_1 / rTunnel_2 = 1024px wide, view = 1280px)
if (room == rTunnel || room == rTunnel_1 || room == rTunnel_2)
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

// --- HP BAR BOSS (colt dreapta-sus, doar cat camera e blocata — boss room) ───────
// Pusa pe oCamera (nu oHUD) pentru ca oCamera exista garantat in orice room,
// inclusiv cand testezi direct BossRoom_1/BossRoom2 fara sa treci prin rMenu
// (oHUD e persistent, dar e plasat doar in rMenu — nu exista deloc altfel)
// NOTA: HP_bar_filler trebuie sa fie ALB (nu negru/verde) — draw_sprite_part_ext
// inmulteste pixelul cu _hp_color, iar alb*culoare = culoare curata (negru*culoare=negru mereu,
// deci ramane invizibil pe fond intunecat cat timp sprite-ul e negru)
if (cam_locked && instance_exists(oBoss1))
{
    var _boss     = oBoss1;
    var _hp_scale = 4.0; // sprite-ul e deja lat nativ (64x40) — scalare uniforma, ajusteaza aici

    // Fereastra de fill din interiorul ramei (bbox real al sprite-ului HP_bar_filler nou, verificat pe pixeli)
    var _bl = 17;
    var _bt = 24;
    var _bw = 53 - 17;
    var _bh = 26 - 24;

    var _bar_w = sprite_get_width(HP_bar_Boss1) * _hp_scale;
    var _bar_x = 1280 - 12 - _bar_w;
    var _bar_y = 12;

    var _pct = clamp(_boss.hp / _boss.max_hp, 0, 1);

    var _hp_color;
    if (_pct > 0.6)      _hp_color = c_lime;
    else if (_pct > 0.3) _hp_color = c_yellow;
    else                 _hp_color = c_red;

    // Fill-ul se deseneaza PRIMUL — fereastra ramei e transparenta, deci rama
    // desenata peste acopera orice exces al fill-ului dincolo de fereastra
    var _fill_w = _bw * _pct;
    if (_fill_w > 0)
        draw_sprite_part_ext(HP_bar_filler, 0, _bl, _bt, _fill_w, _bh,
            _bar_x + _bl * _hp_scale, _bar_y + _bt * _hp_scale, _hp_scale, _hp_scale, _hp_color, 1);

    // Rama de piatra — fixa, desenata deasupra fill-ului
    draw_sprite_ext(HP_bar_Boss1, 0, _bar_x, _bar_y, _hp_scale, _hp_scale, 0, c_white, 1);
}

// --- HP BAR BOSS2 (Strigoi) — acelasi principiu, alta rama ────────────────────
// HP_Boss2 are fereastra de fill in alta pozitie decat HP_bar_Boss1 (16,27→53,29,
// nu 17,24→53,26), deci sursa (din HP_bar_filler) si destinatia (in rama) NU mai
// sunt aceleasi coordonate — trebuie separate, spre diferenta de blocul de mai sus.
// Nu se arata cat oBoss2 e inca in starile de aparitie (ceata inca in scena) —
// abia dupa ce boss-ul s-a "revelat" efectiv (stare != appearing_*)
if (cam_locked && instance_exists(oBoss2) && string_pos("appearing", oBoss2.state) != 1)
{
    var _boss2     = oBoss2;
    var _hp_scale2 = 4.0;

    // Sursa fill — locul din HP_bar_filler unde e desenat efectiv (neschimbat)
    var _sl2 = 17;
    var _st2 = 24;
    var _sw2 = 53 - 17;
    var _sh2 = 26 - 24;

    // Destinatie — fereastra reala din rama HP_Boss2
    var _dl2 = 16;
    var _dt2 = 27;
    var _dw2 = 53 - 16;

    var _bar_w2 = sprite_get_width(HP_Boss2) * _hp_scale2;
    var _bar_x2 = 1280 - 12 - _bar_w2;
    var _bar_y2 = 12;

    var _pct2 = clamp(_boss2.hp / _boss2.max_hp, 0, 1);

    var _hp_color2;
    if (_pct2 > 0.6)      _hp_color2 = c_lime;
    else if (_pct2 > 0.3) _hp_color2 = c_yellow;
    else                  _hp_color2 = c_red;

    var _fill_w2 = _dw2 * _pct2; // procent din latimea ferestrei REALE a ramei
    if (_fill_w2 > 0)
        draw_sprite_part_ext(HP_bar_filler, 0, _sl2, _st2, min(_fill_w2, _sw2), _sh2,
            _bar_x2 + _dl2 * _hp_scale2, _bar_y2 + _dt2 * _hp_scale2, _hp_scale2, _hp_scale2, _hp_color2, 1);

    draw_sprite_ext(HP_Boss2, 0, _bar_x2, _bar_y2, _hp_scale2, _hp_scale2, 0, c_white, 1);
}
