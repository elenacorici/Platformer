function Boss1_Phase1_Patrol() {

    if (state == "patrol") {
        x += patrol_speed * patrol_dir;
        facing = -patrol_dir;

        // Shake + particule la fiecare pas (frame 2 și frame 6)
        var _fi = floor(image_index);
        var _fp = floor(prev_image_index);
        if ((_fi == 2 && _fp != 2) || (_fi == 6 && _fp != 6)) {
            ScreenShake(2, 7);
            var _bot = y + (sprite_get_height(sprite_index) - sprite_get_yoffset(sprite_index)) * boss_scale - 15;
            part_particles_create(p_sys, x, _bot, p_dirt, 10);
        }

        // Ajuns la margine → idle scurt, întoarce direcția
        if (abs(x - patrol_origin) >= patrol_range) {
            x = patrol_origin + patrol_range * patrol_dir;
            patrol_dir = -patrol_dir;
            state = "patrol_idle";
            sprite_index = sBoss1I;
            image_index = 0;
            image_speed = idle_image_speed;
            patrol_idle_timer = patrol_idle_duration;
        }
    }

    if (state == "patrol_idle") {
        patrol_idle_timer--;
        if (patrol_idle_timer <= 0) {
            state = "idle";
            sprite_index = sBoss1I;
            image_index = 0;
            image_speed = idle_image_speed;
            attack_cooldown = 0; // decide imediat următoarea acțiune
        }
    }

}
