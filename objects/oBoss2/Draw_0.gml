draw_self();

if (flash > 0)
{
    shader_set(shWhite);
    draw_self();
    shader_reset();
}

// HP bar
if (state != "grave")
{
    var _bw      = 100;
    var _spr_h   = sprite_get_height(sprite_index) * abs(image_yscale);
    var _bx      = x - _bw * 0.5;
    var _by      = y - _spr_h - 10;
    var _percent = (max_hp > 0) ? clamp(hp / max_hp, 0, 1) : 0;

    draw_set_color(c_red);
    draw_rectangle(_bx, _by, _bx + _bw, _by + 8, false);

    draw_set_color(c_green);
    draw_rectangle(_bx, _by, _bx + _bw * _percent, _by + 8, false);

    draw_set_color(c_white);
}
