function Boss1_Phase3_Ivy() {

    // Windup → spawn ivy
    if (state == "attack_ivy") {
        if (floor(image_index) >= 5) {
            image_speed = 0;
            image_index = 5;
            if (instance_exists(oPlayer)) {
                var _px = oPlayer.x;
                var _py = oPlayer.y + 45;
                attack_ivy_inst1 = instance_create_layer(_px, _py, boss_layer, oIvy);
            }
            state = "attack_ivy_wait";
        }
    }

    // Înghețat pe frame 5 cât timp vita e activă → sare spre player
    if (state == "attack_ivy_wait") {
        // Dacă playerul e stunnat → sare spre el
        if (instance_exists(oPlayer) && oPlayer.is_stunned && place_meeting(x, y + 1, oWall)) {
            state = "attack_ivy_hop";
            sprite_index = sBoss1J;
            image_index = sprite_get_number(sBoss1J) - 1; // direct în aer
            image_speed = 0;
            var _hop_dir = sign(oPlayer.x - x);
            hsp = _hop_dir * 4;
            vsp = -5;
            ScreenShake(3, 10);
            var _bot = y + (sprite_get_height(sBoss1J) - sprite_get_yoffset(sBoss1J)) * boss_scale - 15;
            part_particles_create(p_sys, x, _bot, p_dirt, 15);
        }

        if (!instance_exists(attack_ivy_inst1)) {
            hsp = 0;
            state = "attack_ivy_end";
            image_index = 5;
            image_speed = 0.3;
            sprite_index = sBossA1;
        }
    }

    // Hop în timp ce player e stunnat
    if (state == "attack_ivy_hop") {
        // Mișcare orizontală
        if (!place_meeting(x + hsp, y, oWall))
            x += hsp;
        else
            hsp = 0;

        // Hitbox activ în aer
        var _old_mask = mask_index;
        mask_index = sBossLHB;
        var _hit_list = ds_list_create();
        var _hits = instance_place_list(x, y, oPlayer, _hit_list, false);
        for (var _i = 0; _i < _hits; _i++) {
            with (_hit_list[| _i]) {
                hp -= 2; // combo bonus — player e stunnat
                hp = max(0, hp);
                flash = 3;
                hitfrom = point_direction(other.x, other.y, x, y);
            }
        }
        ds_list_destroy(_hit_list);
        mask_index = _old_mask;

        // Aterizare
        if (place_meeting(x, y + 1, oWall) && vsp >= 0) {
            hsp = 0;
            vsp = 0;
            ScreenShake(6, 20);
            var _bot = y + (sprite_get_height(sBossL) - sprite_get_yoffset(sBossL)) * boss_scale - 15;
            part_particles_create(p_sys, x - 40, _bot, p_dirt, 30);
            part_particles_create(p_sys, x + 40, _bot, p_dirt, 30);

            // Vita încă activă → recover și așteaptă
            // Vita terminată → end animație
            if (!instance_exists(attack_ivy_inst1)) {
                state = "attack_ivy_end";
                sprite_index = sBossA1;
                image_index = 5;
                image_speed = 0.3;
            } else {
                state = "attack_ivy_wait";
                sprite_index = sBossA1;
                image_index = 5;
                image_speed = 0;
            }
        }
    }

    // Lasă mâinile în jos → idle
    if (state == "attack_ivy_end") {
        if (image_index < prev_image_index) {
            state = "idle";
            sprite_index = sBoss1I;
            image_index = 0;
            image_speed = idle_image_speed;
        }
    }

}
