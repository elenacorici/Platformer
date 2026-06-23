var _p = other;
_p.chamomile_count++;

if (_p.chamomile_count >= 3) {
    _p.chamomile_count = 0;
    _p.max_hearts++;
    _p.max_hp += 2;
    _p.hp = min(_p.hp + 2, _p.max_hp);
    _p.hp_temp = _p.hp;
    _p.heart_shake = 8;
}

var _ps = part_system_create_layer(layer, false);
var _pt = part_type_create();
part_type_shape(_pt, pt_shape_pixel);
part_type_size(_pt, 1, 2, -0.05, 0);
part_type_color2(_pt, c_yellow, c_white);
part_type_alpha2(_pt, 1, 0);
part_type_life(_pt, 25, 45);
part_type_speed(_pt, 2, 5, -0.1, 0);
part_type_direction(_pt, 0, 360, 0, 30);
part_type_gravity(_pt, 0.05, 270);
part_particles_create(_ps, x, y, _pt, 20);
part_type_destroy(_pt);

instance_destroy();
