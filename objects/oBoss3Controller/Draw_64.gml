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

// Health bar-urile apar abia dupa ce hora #2 (atacul de start) se termina si
// Ielele se imprastie dramatic (combat_visible), nu la simpla apasare a lui E
if (fight_ended || !fight_started || !combat_visible) exit;

// Sprite-uri dedicate per Iela (HpIala1/2/3) — fereastra de fill e acum
// TRANSPARENTA (schimbat de user, era alba) — identica la toate 3, verificata
// pe pixeli: x:19-55 y:33-35 (37x3). Cum fereastra e transparenta, ORDINEA
// se inverseaza fata de versiunea veche: fill-ul (+ umbra) se deseneaza
// INTAI, rama vine ULTIMA peste, ca sa acopere orice exces si sa arate
// marginile intacte. Umbra = shading in aceeasi nuanta cu fill-ul curent
// (verde inchis / galben-maro / rosu inchis), nu alb/transparent — practica
// standard de HP bar (verificat), ca "viata pierduta" sa citeasca clar drept
// gol, nu ca un artefact vizual.
var _bar_sprites = [HpIala1, HpIala2, HpIala3];
var _hp_scale    = 2.2; // marit fata de 1.6 — ajusteaza
var _bl = 19; var _bt = 33; var _bw = 55 - 19; var _bh = 36 - 33;

var _bar_w = sprite_get_width(HpIala1) * _hp_scale;
var _bar_x = display_get_gui_width() - 12 - _bar_w;
var _bar_y = 12;
var _step  = 75; // distanta verticala intre bare — ajusteaza

for (var _i = 0; _i < 3; _i++)
{
    if (!instance_exists(iele[_i])) { _bar_y += _step; continue; }

    var _ref = iele[_i];
    var _pct = (_ref.hp_max > 0) ? clamp(_ref.hp / _ref.hp_max, 0, 1) : 0;

    var _hp_color;
    if (_ref.rage_active)  _hp_color = c_red;
    else if (_pct > 0.6)   _hp_color = c_lime;
    else if (_pct > 0.3)   _hp_color = c_yellow;
    else                   _hp_color = c_red;

    var _shadow_color = merge_colour(_hp_color, c_black, 0.55);
    var _draw_alpha    = (_ref.is_dead) ? 0.25 : 1.0;

    // Umbra pe toata fereastra ("viata pierduta") — shading al culorii curente
    draw_set_color(_shadow_color);
    draw_set_alpha(_draw_alpha);
    draw_rectangle(_bar_x + _bl * _hp_scale,         _bar_y + _bt * _hp_scale,
                    _bar_x + (_bl + _bw) * _hp_scale, _bar_y + (_bt + _bh) * _hp_scale, false);

    // Fill-ul curent, deasupra umbrei, doar pe portiunea de hp ramas
    if (!_ref.is_dead && _pct > 0)
    {
        var _fill_w = _bw * _pct;
        draw_set_color(_hp_color);
        draw_set_alpha(1);
        draw_rectangle(_bar_x + _bl * _hp_scale,             _bar_y + _bt * _hp_scale,
                        _bar_x + (_bl + _fill_w) * _hp_scale, _bar_y + (_bt + _bh) * _hp_scale, false);
    }

    // Rama — ULTIMA, deasupra fill-ului+umbrei (fereastra e transparenta acum)
    draw_sprite_ext(_bar_sprites[_i], 0, _bar_x, _bar_y, _hp_scale, _hp_scale, 0,
        c_white, (_ref.is_dead) ? 0.35 : 1.0);

    _bar_y += _step;
}

draw_set_color(c_white);
draw_set_alpha(1);
