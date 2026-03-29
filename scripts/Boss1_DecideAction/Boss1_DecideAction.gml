/// @func Boss1_DecideAction()
/// @desc Calculează weight-uri per atac și alege unul. Apelat când attack_cooldown <= 0.

function Boss1_DecideAction() {
    if (!instance_exists(oPlayer)) return;

    var dist     = point_distance(x, y, oPlayer.x, oPlayer.y);
    var hp_ratio = hp / max_hp;
    var on_ground = place_meeting(x, y + 1, oWall);

    // ── SCORURI ────────────────────────────────────
    var actions = ["patrol", "attack_hop", "attack_ivy", "attack_slam"];
    var weights = array_create(4, 0);

    // Phase 1 — Patrol (dist > 300)
    weights[0] = (dist > 300) ? 3 : 0.3;

    // Phase 2 — Hop (dist > 150, pe sol, cooldown gata)
    if (on_ground && hop_cooldown <= 0 && dist > 150)
        weights[1] = dist / 100; // mai departe = mai tentat să sară
    else
        weights[1] = 0;

    // Phase 3 — Ivy (dist > 350, cooldown gata)
    if (ivy_cooldown <= 0 && dist > 350)
        weights[2] = 2;
    else
        weights[2] = 0;

    // Phase 4 — Slam (dist < 150, pe sol, cooldown gata)
    if (slam_cooldown <= 0 && dist < 150 && on_ground)
        weights[3] = 3; // foarte probabil când playerul e aproape
    else
        weights[3] = 0;

    // HP < 50% — boss mai agresiv
    if (hp_ratio < 0.5) {
        weights[1] *= 1.5;
        weights[2] *= 1.5;
        weights[3] *= 1.5;
        weights[0] *= 0.5;
    }

    // ── DECIZIE ────────────────────────────────────
    var chosen = weighted_pick(actions, weights);

    switch (chosen) {
        case "patrol":
            state = "patrol";
            sprite_index = sBoss1W;
            image_index = 0;
            image_speed = 0.15;
            patrol_origin = x;
            attack_cooldown = 180; // 6 secunde până la următoarea decizie
            break;

        case "attack_hop":
            state = "attack_hop_windup";
            sprite_index = sBoss1J;
            image_index = 0;
            prev_image_index = 0;
            image_speed = 0.3;
            hsp = 0;
            hop_cooldown = 300; // 10 secunde cooldown hop
            attack_cooldown = 60;
            break;

        case "attack_ivy":
            state = "attack_ivy";
            sprite_index = sBossA1;
            image_index = 0;
            prev_image_index = 0;
            image_speed = 0.15;
            ivy_cooldown = 240;
            attack_cooldown = 60;
            break;

        case "attack_slam":
            state = "attack_slam";
            sprite_index = sBoss1A2;
            image_index = 0;
            prev_image_index = 0;
            image_speed = 0.15;
            slam_cooldown = 180;
            attack_cooldown = 60;
            break;
    }
}
