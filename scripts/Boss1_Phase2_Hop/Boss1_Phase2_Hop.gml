function Boss1_Phase2_Hop() {

    // Windup → lansare
    if (state == "attack_hop_windup") {
        if (image_index < prev_image_index) {
            state = "attack_hop_air";
            image_index = sprite_get_number(sBoss1J) - 1;
            image_speed = 0;
            if (instance_exists(oPlayer)) {
                var _hop_dir = sign(oPlayer.x - x);
                hsp = _hop_dir * 4;
            }
            vsp = -5;
            ScreenShake(3, 10);
            var _bot = y + (sprite_get_height(sprite_index) - sprite_get_yoffset(sprite_index)) * boss_scale - 15;
            part_particles_create(p_sys, x, _bot, p_dirt, 20);
        }
    }

    // În aer
    if (state == "attack_hop_air") {
        if (!place_meeting(x + hsp, y, oWall))
            x += hsp;
        else
            hsp = 0;

        if (vsp > 0) {
            state = "attack_hop_land";
            sprite_index = sBossL;
            image_index = 0;
            prev_image_index = 0;
            image_speed = 0.12;
        }
    }

    // Aterizare
    if (state == "attack_hop_land") {
        if (!place_meeting(x + hsp, y, oWall))
            x += hsp;
        else
            hsp = 0;

        if (place_meeting(x, y + 1, oWall) && vsp >= 0) {
            if (vsp > 0) {
                ScreenShake(6, 20);
                var _bot = y + (sprite_get_height(sprite_index) - sprite_get_yoffset(sprite_index)) * boss_scale - 15;
                part_particles_create(p_sys, x - 40, _bot, p_dirt, 30);
                part_particles_create(p_sys, x + 40, _bot, p_dirt, 30);
            }
            hsp = 0;
            vsp = 0;
        }

        if (image_index < prev_image_index) {
            state = "attack_hop_recover";
            image_index = sprite_get_number(sBossL) - 1;
            image_speed = 0;
            hop_recover_timer = 50;
        }
    }

    // Recover
    if (state == "attack_hop_recover") {
        hop_recover_timer--;
        if (hop_recover_timer <= 0) {
            state = "idle";
            sprite_index = sBoss1I;
            image_index = 0;
            image_speed = idle_image_speed;
        }
    }

}
