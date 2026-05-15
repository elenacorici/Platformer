if (!instance_exists(ivy_parent)) exit;

var _par = ivy_parent;

if (_par.phase == "stun") {
    // Sandwich — fața lianei, aceeași poziție ca oIvy
    draw_sprite_ext(sVineFront, 0,
        _par.x, _par.y,
        _par.image_xscale, _par.image_yscale,
        0, c_white, 1);
} else {
    // Grow/retract — jumătatea de JOS din animație
    var _spr = _par.sprite_index;
    var _idx = _par.image_index;
    var _sx  = _par.image_xscale;
    var _sy  = _par.image_yscale;
    var _split = 32;
    var _spr_w = sprite_get_width(_spr);
    var _spr_h = sprite_get_height(_spr);
    var _ox = _par.x - sprite_get_xoffset(_spr) * _sx;
    var _oy = _par.y - sprite_get_yoffset(_spr) * _sy;

    draw_sprite_part_ext(_spr, _idx,
        0, _split,
        _spr_w, _spr_h - _split,
        _ox, _oy + _split * _sy,
        _sx, _sy, c_white, 1);
}
