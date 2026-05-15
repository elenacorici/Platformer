if (damage_cooldown > 0) damage_cooldown--;

switch (state)
{
    // ── ENTER — zboară spre player cu homing ─────────────
    case "enter":
        if (instance_exists(oPlayer))
        {
            var _target = point_direction(x, y, oPlayer.x, oPlayer.y);
            var _diff   = angle_difference(_target, direction);
            direction  += clamp(_diff, -turnSpeed, turnSpeed);
        }
        hspeed = lengthdir_x(velocity, direction);
        vspeed = lengthdir_y(velocity, direction);

        // Odată ajuns lângă player → trece la orbit
        if (instance_exists(oPlayer)
            && point_distance(x, y, oPlayer.x, oPlayer.y) < orbit_radius + 20)
        {
            state  = "orbit";
            hspeed = 0;
            vspeed = 0;
        }
        break;

    // ── ORBIT — roiește în cerc în jurul player-ului ─────
    case "orbit":
        if (instance_exists(oPlayer))
        {
            orbit_angle += orbit_speed;

            var _tx = oPlayer.x + lengthdir_x(orbit_radius, orbit_angle);
            var _ty = oPlayer.y + lengthdir_y(orbit_radius * 0.6, orbit_angle) - 10;

            // Mișcare fluidă spre punctul de orbită
            x += (_tx - x) * 0.28;
            y += (_ty - y) * 0.28;

            // Damage la proximitate (nu în fiecare frame)
            if (damage_cooldown <= 0
                && point_distance(x, y, oPlayer.x, oPlayer.y) < 30)
            {
                with (oPlayer)
                {
                    hp--;
                    hp    = max(0, hp);
                    flash = 3;
                }
                damage_cooldown = 60; // 1 damage pe secundă max
            }
        }

        orbit_timer--;
        if (orbit_timer <= 0)
        {
            state     = "exit";
            direction = 180; // spre stânga
            hspeed    = 0;
            vspeed    = 0;
        }
        break;

    // ── EXIT — zboară spre stânga și dispare ─────────────
    case "exit":
        hspeed = -exit_speed;
        vspeed = 0;

        if (x < camera_get_view_x(view_camera[0]) - 100)
            instance_destroy();
        break;
}

// Flip sprite pe direcție orizontală
if (hspeed != 0)
    image_xscale = (hspeed < 0) ? -2.5 : 2.5;
