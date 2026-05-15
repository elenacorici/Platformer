/// @func Boss2_DecideAction()
function Boss2_DecideAction()
{
    if (!instance_exists(oPlayer)) return;

    var _dist      = point_distance(x, y, oPlayer.x, oPlayer.y);
    var _on_ground = place_meeting(x, y + 1, oWall);

    var _actions = ["attack_spit", "attack_bats", "attack_wolf", "walk"];
    var _weights = array_create(4, 0);

    // ── ZONĂ DEPARTE (>400px) — Spit ────────────────────────
    if (spit_cooldown <= 0 && _on_ground && _dist >= 400)
    {
        _weights[0] = 4;
        if (last_attack == "attack_spit") _weights[0] *= 0.2;
    }

    // ── ZONĂ MEDIE (150-400px) — Lilieci ────────────────────
    if (bats_cooldown <= 0 && _on_ground && _dist >= 150 && _dist < 400)
    {
        _weights[1] = 3;
        if (last_attack == "attack_bats") _weights[1] *= 0.2;
    }

    // ── ZONĂ DEPARTE (>400px) — Lup, doar Phase 2 ───────────
    if (phase == 2 && wolf_cooldown <= 0 && _on_ground && _dist >= 400)
    {
        _weights[2] = 3;
        if (last_attack == "attack_wolf") _weights[2] *= 0.2;
    }

    // ── WALK — fallback ──────────────────────────────────────
    _weights[3] = 1;

    var _chosen = weighted_pick(_actions, _weights);

    // Cooldown-uri diferite per fază
    var _atk_cd   = (phase == 2) ? 60  : 90;
    var _spit_cd  = (phase == 2) ? 140 : 220;
    var _bats_cd  = (phase == 2) ? 200 : 300;
    var _wolf_cd  = 280;

    switch (_chosen)
    {
        case "attack_spit":
            state            = "attack_spit";
            sprite_index     = sBoss2Attack1;
            image_index      = 0;
            image_speed      = 0.17; // 10 FPS
            prev_image_index = 0;
            spit_cooldown    = _spit_cd;
            attack_cooldown  = _atk_cd;
            last_attack      = "attack_spit";
            hsp = 0;
            break;

        case "attack_bats":
            state            = "attack_bats";
            sprite_index     = sBoss2Attack2;
            image_index      = 0;
            image_speed      = 0.17; // 10 FPS
            prev_image_index = 0;
            bats_cooldown    = _bats_cd;
            attack_cooldown  = _atk_cd;
            last_attack      = "attack_bats";
            hsp = 0;
            break;

        case "attack_wolf":
            state            = "attack_wolf_spin";
            sprite_index     = sBoss2Attack3P1;
            image_index      = 0;
            image_speed      = 0.2;
            prev_image_index = 0;
            wolf_cooldown    = _wolf_cd;
            attack_cooldown  = _atk_cd;
            last_attack      = "attack_wolf";
            hsp = 0;
            break;

        default: // walk
            state           = "walk";
            attack_cooldown = _atk_cd;
            break;
    }
}
