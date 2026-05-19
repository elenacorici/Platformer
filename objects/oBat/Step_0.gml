if (damage_cooldown > 0) damage_cooldown--;

// ── MORT — nu mai rulează logica normală ─────────────────
if (state == "dying" || state == "dead")
{
    if (state == "dying")
    {
        // Cade spre podea
        vspeed += 0.4;
        y += vspeed;

        // Se oprește la podea
        if (place_meeting(x, y + 1, oWall))
        {
            vspeed = 0;
            // Animație moarte se termină → rămâne ultimul frame
            if (animation_end())
            {
                state        = "dead";
                image_index  = sprite_get_number(bat_die) - 1;
                image_speed  = 0;
                dead_timer   = 180; // 3 secunde pe podea
            }
        }
    }
    else // "dead"
    {
        dead_timer--;
        // Fade out în ultimul secund
        if (dead_timer < 60)
            image_alpha = dead_timer / 60;
        if (dead_timer <= 0)
            instance_destroy();
    }
    exit;
}

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
            x += (_tx - x) * 0.28;
            y += (_ty - y) * 0.28;

            if (damage_cooldown <= 0
                && point_distance(x, y, oPlayer.x, oPlayer.y) < 30)
            {
                with (oPlayer)
                {
                    hp--;
                    hp    = max(0, hp);
                    flash = 3;
                }
                damage_cooldown = 60;
            }
        }

        orbit_timer--;
        if (orbit_timer <= 0)
        {
            state     = "exit";
            direction = 180;
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

// Flip sprite pe direcție orizontală (nu în moarte)
if (state != "dying" && state != "dead" && hspeed != 0)
    image_xscale = (hspeed < 0) ? -2.5 : 2.5;
