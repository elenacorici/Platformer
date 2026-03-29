/// @func Boss1_Phase4_Slam()
function Boss1_Phase4_Slam() {

    // Windup → la frame 6 activăm hitbox-ul și dăm damage
    if (state == "attack_slam") {
        var _fi = floor(image_index);
        var _fp = floor(prev_image_index);

        // Frame 7 = începe căderea rapidă
        if (_fi == 7 && _fp != 7) image_speed = 0.5;

        // Frame 6 = momentul impactului
        if (_fi == 6 && _fp != 6) {
            image_speed = 0.15;
            ScreenShake(5, 15);
            var _bot = y + (sprite_get_height(sprite_index) - sprite_get_yoffset(sprite_index)) * boss_scale - 15;
            part_particles_create(p_sys, x - 30, _bot, p_dirt, 20);
            part_particles_create(p_sys, x + 30, _bot, p_dirt, 20);
        }

        // Hitbox activ frames 6-8
        if (_fi >= 6 && _fi <= 8) {
            var _old_mask = mask_index;
            mask_index = sBoss1A2HB;
            var _hit_list = ds_list_create();
            var _hits = instance_place_list(x, y, oPlayer, _hit_list, false);
            for (var _i = 0; _i < _hits; _i++) {
                var _pid = _hit_list[| _i];
                if (ds_list_find_index(slam_hit_list, _pid) == -1) {
                    ds_list_add(slam_hit_list, _pid);
                    with (_pid) {
                        hp--;
                        hp = max(0, hp);
                        flash = 3;
                        hitfrom = point_direction(other.x, other.y, x, y);
                    }
                }
            }
            ds_list_destroy(_hit_list);
            mask_index = _old_mask;
        }

        // Animație terminată → recover
        if (floor(image_index) >= sprite_get_number(sBoss1A2) - 1) {
            state = "attack_slam_recover";
            image_index = sprite_get_number(sBoss1A2) - 1;
            image_speed = 0;
            slam_recover_timer = 60;
            ds_list_clear(slam_hit_list);
        }
    }

    // Stă aplecat → idle
    if (state == "attack_slam_recover") {
        slam_recover_timer--;
        if (slam_recover_timer <= 0) {
            state = "idle";
            sprite_index = sBoss1I;
            image_index = 0;
            image_speed = idle_image_speed;
        }
    }

}
