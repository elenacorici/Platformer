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
