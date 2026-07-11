switch (state)
{
    case "idle":
        // Asteapta declansarea externa (oBossCamTrigger seteaza state="wake")
        break;

    case "wake":
        if (animation_end())
        {
            state        = "covering";
            cover_timer  = 0;
            cover_delay  = 240; // ~4 secunde (60fps) inainte sa apara boss-ul, cat sa se aseze ceata+frunzele

            ScreenShake(5, 90);

            // Ceata + ploaie de frunze in jurul copacului — nu se apeleaza part_type_destroy,
            // altfel particulele deja create ar fi ucise inainte sa expire (ca la oGrave)
            var _ps = part_system_create_layer("Particles", false);

            // ── CEATA (arie mai mica decat la oGrave — concentrata la copac) ──────
            var _ptf1 = part_type_create();
            part_type_shape(_ptf1, pt_shape_pixel);
            part_type_size(_ptf1, 2, 6, -0.14, 0);
            part_type_colour3(_ptf1, make_colour_rgb(190, 185, 215),
                                     make_colour_rgb(150, 142, 178),
                                     make_colour_rgb(90,  83,  120));
            part_type_alpha2(_ptf1, 0.9, 0.0);
            part_type_speed(_ptf1, 1, 3, -0.08, 0);
            part_type_direction(_ptf1, 0, 360, 0, 40);
            part_type_gravity(_ptf1, 0.2, 270);
            part_type_life(_ptf1, 18, 34);
            part_particles_create(_ps, x, y, _ptf1, 110);

            var _ptf2 = part_type_create();
            part_type_shape(_ptf2, pt_shape_cloud);
            part_type_size(_ptf2, 0.5, 1.5, 0.04, 0.04);
            part_type_colour3(_ptf2, make_colour_rgb(200, 195, 230),
                                     make_colour_rgb(170, 162, 205),
                                     make_colour_rgb(110, 100, 145));
            part_type_alpha3(_ptf2, 0.35, 0.42, 0.0);
            part_type_speed(_ptf2, 0.4, 1.2, -0.015, 0.03);
            part_type_direction(_ptf2, 60, 120, 0, 15);
            part_type_gravity(_ptf2, 0.015, 270);
            part_type_life(_ptf2, 220, 320);
            part_particles_create(_ps, x,      y,      _ptf2, 70);
            part_particles_create(_ps, x + 15, y + 10, _ptf2, 70);

            // ── FRUNZE (instante oLeaf, nu particule — ca sa poata ateriza exact la
            //    ground_y si sa se opreasca din rotit, lucruri pe care particulele
            //    simple nu le pot face). Imprastiate mult mai larg decat inainte,
            //    cad de la inaltimea coroanei copacului si se aseaza pe sol.
            repeat (70)
            {
                var _lx = x + random_range(-220, 220);
                var _ly = y - random_range(80, 280);
                instance_create_layer(_lx, _ly, "Particles", oLeaf);
            }
        }
        break;

    case "covering":
        cover_timer++;
        if (cover_timer >= cover_delay)
        {
            var _boss = instance_create_layer(x, y, "Enemies", oBoss1);
            _boss.state         = "idle";
            _boss.patrol_origin = x;

            instance_destroy();
        }
        break;
}
