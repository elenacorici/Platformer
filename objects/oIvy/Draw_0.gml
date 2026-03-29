var _spr = sprite_index;
var _idx = image_index;
var _sx = image_xscale;
var _sy = image_yscale;
var _split = 35;
var _total = 64;

// Jumătatea de JOS — în FAȚA player-ului
gpu_set_depth(oPlayer.depth - 1);
draw_sprite_part_ext(_spr, _idx,
    0, _split,
    sprite_width, _total - _split,
    x, y + _split * _sy,
    _sx, _sy, c_white, 1);

// Jumătatea de SUS — în SPATELE player-ului
gpu_set_depth(oPlayer.depth + 1);
draw_sprite_part_ext(_spr, _idx,
    0, 0,
    sprite_width, _split,
    x, y,
    _sx, _sy, c_white, 1);
