function Boss1_Phase3_Ivy() {

    // Windup → spawn ivy
    if (state == "attack_ivy") {
        if (floor(image_index) >= 5) {
            image_speed = 0;
            image_index = 5;
            if (instance_exists(oPlayer)) {
                var _px = oPlayer.x;
                var _py = oPlayer.y + 45;
                attack_ivy_inst1 = instance_create_layer(_px, _py, layer, oIvy);
            }
            state = "attack_ivy_wait";
        }
    }

    // Înghețat pe frame 5 cât timp vita e activă
    if (state == "attack_ivy_wait") {
        if (!instance_exists(attack_ivy_inst1)) {
            state = "attack_ivy_end";
            image_index = 5;
            image_speed = 0.3;
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
