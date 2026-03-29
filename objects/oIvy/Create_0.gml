phase = "grow";
stun_timer = 90;
image_speed = 0.3;
image_xscale = 2;
image_yscale = 2;
visible = false; // oIvy nu se desenează singur

// Particule pamant
p_sys = part_system_create_layer(layer, false);
part_system_depth(p_sys, -100);
p_dirt = part_type_create();
part_type_shape(p_dirt, pt_shape_pixel);
part_type_size(p_dirt, 4, 9, -0.1, 0);
part_type_colour3(p_dirt, make_colour_rgb(100, 50, 15), make_colour_rgb(70, 35, 10), make_colour_rgb(40, 20, 5));
part_type_alpha2(p_dirt, 1, 0);
part_type_speed(p_dirt, 2, 6, -0.15, 0);
part_type_direction(p_dirt, 60, 120, 0, 20);
part_type_gravity(p_dirt, 0.3, 270);
part_type_life(p_dirt, 20, 40);

particles_spawned = false;

// Spawns cele 2 jumătăți
ivy_back = instance_create_layer(x, y, layer, oIvyBack);
ivy_back.ivy_parent = id;

ivy_front = instance_create_layer(x, y, layer, oIvyFront);
ivy_front.ivy_parent = id;
