// ── Vigneta pulsanta: dialog "Apasa E" + prima hora de combat ─
// Controlata exclusiv de timer (set la aparitia dialogului, golit de _end_hora).
// Nu depinde de hora_active — garantat se opreste.
if (intro_vignette_timer > 0) intro_vignette_timer--;

if (intro_vignette_timer > 0)
{
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _t  = current_time / 1000.0;
    var _a  = 0.32 + sin(_t * 2.8) * 0.14; // puls lent ~2.2 sec, intre 0.18 si 0.46
    var _e  = 300;                           // latime margine intunecata
    var _c  = c_black;

    gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha);

    draw_primitive_begin(pr_trianglestrip);  // stanga
    draw_vertex_colour(0,   0,   _c, _a); draw_vertex_colour(_e,  0,   _c, 0);
    draw_vertex_colour(0,   _gh, _c, _a); draw_vertex_colour(_e,  _gh, _c, 0);
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);  // dreapta
    draw_vertex_colour(_gw-_e, 0,   _c, 0); draw_vertex_colour(_gw, 0,   _c, _a);
    draw_vertex_colour(_gw-_e, _gh, _c, 0); draw_vertex_colour(_gw, _gh, _c, _a);
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);  // sus
    draw_vertex_colour(0,   0,   _c, _a); draw_vertex_colour(_gw, 0,   _c, _a);
    draw_vertex_colour(0,   190, _c, 0);  draw_vertex_colour(_gw, 190, _c, 0);
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);  // jos
    draw_vertex_colour(0,   _gh-190, _c, 0);  draw_vertex_colour(_gw, _gh-190, _c, 0);
    draw_vertex_colour(0,   _gh,     _c, _a); draw_vertex_colour(_gw, _gh,     _c, _a);
    draw_primitive_end();

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

// ── Dialog intro ──────────────────────────────────────────────
if (intro_dialog_visible)
{
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _bw = 320;
    var _bh = 64;
    var _bx = (_gw - _bw) * 0.5;
    var _by = _gh - 110;

    draw_set_color(c_black);
    draw_set_alpha(0.78);
    draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);

    draw_set_color(c_white);
    draw_set_alpha(0.9);
    draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);

    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(_bx + _bw * 0.5, _by + 10, "Hai să jucăm cu noi!");
    draw_text(_bx + _bw * 0.5, _by + 36, "[ E ]  Joacă");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

if (fight_ended || !fight_started) exit;

var _x      = display_get_gui_width() - 24;
var _y      = 40;
var _w      = 16;
var _h      = 80;
var _gap    = 24;

for (var _i = 0; _i < 3; _i++)
{
    if (!instance_exists(iele[_i])) { _y += _h + _gap; continue; }

    var _ref  = iele[_i];
    var _fill = (_ref.hp_max > 0) ? (_ref.hp / _ref.hp_max) : 0;

    // Fundal bara
    draw_set_color(c_dkgray);
    draw_set_alpha(0.7);
    draw_rectangle(_x - _w, _y, _x, _y + _h, false);

    // Umplere HP
    var _col;
    if (_ref.rage_active)   _col = c_red;
    else if (_fill > 0.5)   _col = c_lime;
    else if (_fill > 0.25)  _col = c_yellow;
    else                    _col = c_red;
    draw_set_color(_col);
    draw_set_alpha((_ref.is_dead) ? 0.3 : 1.0);
    var _filled_h = _h * _fill;
    draw_rectangle(_x - _w, _y + _h - _filled_h, _x, _y + _h, false);

    // Contur
    draw_set_color((_ref.rage_active) ? c_red : c_white);
    draw_set_alpha(0.9);
    draw_rectangle(_x - _w, _y, _x, _y + _h, true);

    draw_set_alpha(1);
    _y += _h + _gap;
}

draw_set_color(c_white);
draw_set_alpha(1);
