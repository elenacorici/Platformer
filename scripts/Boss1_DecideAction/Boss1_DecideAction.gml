/// @func Boss1_DecideAction()
/// @desc Alege atacul cu weights pe zone + anti-repeat. Apelat când attack_cooldown <= 0.

function Boss1_DecideAction() {
    if (!instance_exists(oPlayer)) return;

    var dist      = point_distance(x, y, oPlayer.x, oPlayer.y);
    var on_ground = place_meeting(x, y + 1, oWall);

    var actions = ["attack_slam", "attack_hop", "attack_ivy", "patrol"];
    var weights = array_create(4, 0);

    // Slam — disponibil aproape
    if (slam_cooldown <= 0 && on_ground && dist < 100) {
        weights[0] = (dist < 50) ? 4 : 2;
        if (last_attack == "attack_slam") weights[0] *= 0.2;
    }

    // Hop — disponibil la distanță medie
    if (hop_cooldown <= 0 && on_ground && dist > 80 && dist < 350) {
        weights[1] = 3;
        if (last_attack == "attack_hop") weights[1] *= 0.2;
    }

    // Ivy — disponibil departe
    if (ivy_cooldown <= 0 && dist > 250) {
        weights[2] = 3;
        if (last_attack == "attack_ivy") weights[2] *= 0.2;
    }

    // Patrol — fallback spre player
    weights[3] = 1;

    var chosen = weighted_pick(actions, weights);

    if (chosen == "attack_slam")  { _boss_do_slam();   last_attack = "attack_slam";  return; }
    if (chosen == "attack_hop")   { _boss_do_hop();    last_attack = "attack_hop";   return; }
    if (chosen == "attack_ivy")   { _boss_do_ivy();    last_attack = "attack_ivy";   return; }

    // Patrol
    state = "patrol";
    sprite_index = sBoss1W;
    image_index = 0;
    image_speed = 0.15;
    patrol_origin = x;
    patrol_dir = sign(oPlayer.x - x);
    attack_cooldown = 90;
}

function _boss_do_hop() {
    state = "attack_hop_windup";
    sprite_index = sBoss1J;
    image_index = 0;
    prev_image_index = 0;
    image_speed = 0.3;
    hsp = 0;
    hop_cooldown = 240;
    attack_cooldown = 60;
}

function _boss_do_ivy() {
    state = "attack_ivy";
    sprite_index = sBossA1;
    image_index = 0;
    prev_image_index = 0;
    image_speed = 0.15;
    ivy_cooldown = 280;
    attack_cooldown = 60;
    ivy_target_x = oPlayer.x;
    ivy_target_y = oPlayer.y;
}

function _boss_do_slam() {
    state = "attack_slam";
    sprite_index = sBoss1A2;
    image_index = 0;
    prev_image_index = 0;
    image_speed = 0.25;
    slam_cooldown = 180;
    attack_cooldown = 60;
}
