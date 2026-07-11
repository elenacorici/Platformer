/// @description Opreste animatia la ultimul frame si face ceata
if (sprite_index == sGraveStart && image_speed > 0
&&  image_index >= sprite_get_number(sGraveStart) - 1)
{
    image_speed  = 0;
    image_index  = sprite_get_number(sGraveStart) - 1;
    sprite_index = sGrave;
    image_index  = 0;

    if (!fog_done)
    {
        fog_done = true;
        show_debug_message("GRAVE PARTICLES FIRED at x=" + string(x) + " y=" + string(y) + " layer=" + string(layer));
        ps_fog = part_system_create_layer("Particles", false);

        // 1. Explozie initiala — particule rapide in toate directiile
        pt_fog = part_type_create();
        part_type_shape(pt_fog, pt_shape_pixel);
        part_type_size(pt_fog, 2, 7, -0.14, 0);
        part_type_colour3(pt_fog, make_colour_rgb(190, 185, 215),
                                  make_colour_rgb(150, 142, 178),
                                  make_colour_rgb(90,  83,  120));
        part_type_alpha2(pt_fog, 0.9, 0.0);
        part_type_speed(pt_fog, 2, 9, -0.13, 0);
        part_type_direction(pt_fog, 0, 360, 0, 40);
        part_type_gravity(pt_fog, 0.35, 270);
        part_type_life(pt_fog, 22, 48);
        part_particles_create(ps_fog, x, 787, pt_fog, 120);

        // 2. Nor de ceata — se umfla si se ridica usor
        pt_fog2 = part_type_create();
        part_type_shape(pt_fog2, pt_shape_cloud);
        part_type_size(pt_fog2, 0.5, 1.8, 0.055, 0.05);
        part_type_colour3(pt_fog2, make_colour_rgb(200, 195, 230),
                                   make_colour_rgb(170, 162, 205),
                                   make_colour_rgb(110, 100, 145));
        part_type_alpha3(pt_fog2, 0.35, 0.42, 0.0);
        part_type_speed(pt_fog2, 1.5, 4.5, -0.01, 0.04);
        part_type_direction(pt_fog2, 50, 130, 0, 15);
        part_type_gravity(pt_fog2, 0.02, 270);
        part_type_life(pt_fog2, 1200, 1800);
        part_particles_create(ps_fog, x, 787, pt_fog2, 90);
        part_particles_create(ps_fog, x, 860, pt_fog2, 90);
    }
}
