// ── Moarte ────────────────────────────────────────────────────
if (is_dead)
{
    hsp = 0;
    vsp += grv;
    if (place_meeting(x, y + vsp, oWall))
    {
        while (!place_meeting(x, y + 1, oWall)) y++;
        vsp = 0;
    }
    else y += vsp;

    if (sprite_index != spr_sit_hit)
    {
        sprite_index = spr_sit_hit;
        image_index  = 0;
        image_speed  = 0.12;
    }
    else if (image_index >= sprite_get_number(spr_sit_hit) - 1)
        image_speed = 0; // îngheață pe ultimul frame

    exit;
}

// ── Fuga (flee) ───────────────────────────────────────────────
if (iele_attack == "flee")
{
    var _fdir = (x < room_width * 0.5) ? -1 : 1;
    hsp       = _fdir * 6;
    x        += hsp;
    facing    = _fdir;
    image_xscale = image_xscale_base * _fdir;

    if (sprite_index != spr_walk) { sprite_index = spr_walk; image_speed = 0.25; }

    vsp += grv;
    if (place_meeting(x, y + vsp, oWall)) { while (!place_meeting(x, y + 1, oWall)) y++; vsp = 0; }
    else y += vsp;

    if (x < -150 || x > room_width + 150)
    {
        if (instance_exists(oBoss3Controller)) oBoss3Controller.fight_ended = true;
        instance_destroy();
    }
    exit;
}

// ── Intro (inainte de inceperea luptei) — nu leviteaza, nu urmareste player ──
if (instance_exists(oBoss3Controller) && !oBoss3Controller.fight_started)
{
    IeleIntro();
    exit;
}

IeleUpdate();
