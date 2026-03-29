// Particule la primul frame de grow
if (phase == "grow" && !particles_spawned) {
    part_particles_create(p_sys, x - 20, y, p_dirt, 25);
    part_particles_create(p_sys, x + 20, y, p_dirt, 25);
    particles_spawned = true;
}

// Primele 3 frame-uri (telegraph) mai lente, restul mai rapide
if (phase == "grow") {
    if (image_index < 3)
        image_speed = 0.12; // lent — timp să se ferească
    else
        image_speed = 0.3;  // normal
}

if (phase == "grow" && animation_end()) {
    image_speed = 0;
    phase = "stun";
    // Mută player-ul în centrul viței și blochează
    if (instance_exists(oPlayer)) {
        oPlayer.x = x;
        oPlayer.y = y - 85;
        oPlayer.vsp = 0;
        oPlayer.hsp = 0;
        oPlayer.is_stunned = true;
        oPlayer.stun_timer = stun_timer;
    }
}

if (phase == "stun") {
    stun_timer--;

    // Ține player-ul fix în centrul viței în fiecare frame
    if (instance_exists(oPlayer)) {
        oPlayer.x = x;
        oPlayer.y = y - 95;
        oPlayer.vsp = 0;
        oPlayer.hsp = 0;
    }

    if (stun_timer <= 0) {
        phase = "retract";
        sprite_index = sVineD;
        image_index = 0;
        image_speed = 0.4;
        // Particule la începutul retractului
        part_particles_create(p_sys, x - 20, y, p_dirt, 25);
        part_particles_create(p_sys, x + 20, y, p_dirt, 25);
        if (instance_exists(oPlayer)) {
            oPlayer.is_stunned = false;
        }
    }
}

if (phase == "retract" && animation_end()) {
    instance_destroy();
}
