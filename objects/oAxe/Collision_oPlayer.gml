other.has_axe = true;

var _ps = part_system_create_layer(layer, false);
var _pt = part_type_create();
part_type_shape(_pt, pt_shape_pixel);
part_type_size(_pt, 1, 3, -0.05, 0);
part_type_color2(_pt, c_orange, c_white);
part_type_alpha2(_pt, 1, 0);
part_type_life(_pt, 25, 45);
part_type_speed(_pt, 2, 6, -0.1, 0);
part_type_direction(_pt, 0, 360, 0, 30);
part_particles_create(_ps, x, y, _pt, 25);
part_type_destroy(_pt);

instance_destroy();
