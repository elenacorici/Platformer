// ── Pe sol — linger si fade ──────────────────────────────────────────────
if (linger_timer >= 0)
{
    linger_timer--;
    image_alpha = linger_timer / 120.0;
    if (linger_timer <= 0) instance_destroy();
    exit;
}

// ── In cadere ────────────────────────────────────────────────────────────
vsp += grv;

// Shadow — collision_point nu depinde de masca bolovanului
shadow_y = -1;
for (var _g = 4; _g < 1600; _g += 4)
{
    if (collision_point(x, y + _g, oWall, false, false) != noone)
    {
        shadow_y = y + _g;
        break;
    }
}

// Damage player in cadere
if (!has_hit && instance_exists(oPlayer))
    if (point_distance(x, y, oPlayer.x, oPlayer.y) < 26)
    {
        has_hit = true;
        with (oPlayer) { hp -= 1; flash = 8; hitfrom = (other.x > x) ? 180 : 0; }
    }

// Impact cu solul
if (place_meeting(x, y + vsp, oWall))
{
    while (!place_meeting(x, y + sign(vsp), oWall))
        y += sign(vsp);

    if (instance_exists(oCamera)) ScreenShake(10, 18);

    // IMPORTANT: fiecare stil de particula are propriul tip separat.
    // Reutilizarea aceluiasi _pt ar suprascrie retroactiv particulele deja emise.
    // Nu se apeleaza part_type_destroy — ar ucide particulele inainte sa expire.
    var _ps = part_system_create_layer("Enemies", false);

    // ── 1. Explozie rapida la impact ─────────────────────────────────────
    var _pt1 = part_type_create();
    part_type_shape(_pt1, pt_shape_pixel);
    part_type_size(_pt1, 2, 7, -0.14, 0);
    part_type_colour3(_pt1, make_colour_rgb(145, 112, 72),
                            make_colour_rgb(105, 76, 46),
                            make_colour_rgb(65, 44, 24));
    part_type_alpha2(_pt1, 1.0, 0.0);
    part_type_speed(_pt1, 2, 9, -0.13, 0);
    part_type_direction(_pt1, 20, 160, 0, 40);
    part_type_gravity(_pt1, 0.35, 270);
    part_type_life(_pt1, 22, 48);
    part_particles_create(_ps, x, y, _pt1, 20);

    // ── 2. Firimituri pe sol — aluneca lateral ────────────────────────────
    var _pt2 = part_type_create();
    part_type_shape(_pt2, pt_shape_pixel);
    part_type_size(_pt2, 1, 3, -0.01, 0);
    part_type_colour3(_pt2, make_colour_rgb(118, 90, 58),
                            make_colour_rgb(85, 64, 40),
                            make_colour_rgb(60, 45, 27));
    part_type_alpha2(_pt2, 0.9, 0.0);
    part_type_speed(_pt2, 0.5, 3.5, -0.04, 0);
    part_type_direction(_pt2, 0, 180, 0, 18);
    part_type_gravity(_pt2, 0.55, 270);
    part_type_life(_pt2, 100, 190);
    part_particles_create(_ps, x, y, _pt2, 14);

    // ── 3. Nor de praf — gri deschis, se ridica putin ────────────────────
    var _pt3 = part_type_create();
    part_type_shape(_pt3, pt_shape_cloud);
    part_type_size(_pt3, 0.5, 1.8, 0.02, 0.04);
    part_type_colour3(_pt3, make_colour_rgb(210, 210, 208),
                            make_colour_rgb(185, 183, 180),
                            make_colour_rgb(155, 153, 150));
    part_type_alpha3(_pt3, 0.32, 0.38, 0.0);
    part_type_speed(_pt3, 0.1, 0.6, -0.01, 0.04);
    part_type_direction(_pt3, 140, 220, 0, 12); // numai lateral, nu urca
    part_type_gravity(_pt3, 0.04, 270); // trage usor in jos — ramane la sol
    part_type_life(_pt3, 300, 500);
    part_particles_create(_ps, x, y, _pt3, 45);

    // ── 4. Praf lateral — se intinde la sol, nu urca ─────────────────────
    var _pt4 = part_type_create();
    part_type_shape(_pt4, pt_shape_cloud);
    part_type_size(_pt4, 0.3, 1.0, 0.015, 0.03);
    part_type_colour3(_pt4, make_colour_rgb(205, 204, 202),
                            make_colour_rgb(178, 176, 173),
                            make_colour_rgb(145, 142, 138));
    part_type_alpha3(_pt4, 0.28, 0.35, 0.0);
    part_type_speed(_pt4, 1.2, 4.0, -0.06, 0.15);
    part_type_direction(_pt4, 120, 240, 0, 10);
    part_type_gravity(_pt4, 0.05, 270); // trage in jos — hugs solul
    part_type_life(_pt4, 200, 340);
    part_particles_create(_ps, x, y, _pt4, 32);

    image_speed  = 0;
    image_angle  = 0;
    linger_timer = 120;
}
else
    y += vsp;
