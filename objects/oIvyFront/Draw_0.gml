if (!instance_exists(ivy_parent)) exit;

var _par = ivy_parent;
var _spr = _par.sprite_index;
var _idx = _par.image_index;
var _sx = _par.image_xscale;
var _sy = _par.image_yscale;
var _split = 32;
var _spr_w = sprite_get_width(_spr);
var _spr_h = sprite_get_height(_spr);
var _ox = _par.x - sprite_get_xoffset(_spr) * _sx;
var _oy = _par.y - sprite_get_yoffset(_spr) * _sy;

// Jumătatea de JOS — în FAȚA player-ului
draw_sprite_part_ext(_spr, _idx,
    0, _split,
    _spr_w, _spr_h - _split,
    _ox, _oy + _split * _sy,
    _sx, _sy, c_white, 1);
