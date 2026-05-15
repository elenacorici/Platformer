vsp += grv;
Enemy_VerticalResolve();

// Facing spre player (nu în stările pasive/moarte)
if (instance_exists(oPlayer)
    && state != "idle"
    && state != "dizzy"
    && state != "dying"
    && state != "grave")
{
    var _dir = sign(oPlayer.x - x);
    if (_dir != 0) facing = -_dir;
}

image_xscale = facing * boss_scale;
image_yscale = boss_scale;


// Actualizare fază
if (instance_exists(oPlayer))
    phase = (hp > max_hp / 2) ? 1 : 2;

// Cooldown-uri
if (attack_cooldown > 0) attack_cooldown--;
if (spit_cooldown   > 0) spit_cooldown--;
if (bats_cooldown   > 0) bats_cooldown--;
if (wolf_cooldown   > 0) wolf_cooldown--;
if (flash           > 0) flash--;

// ── IDLE ────────────────────────────────────────────────
if (state == "idle")
{
    sprite_index = sBoss2Idle;
    image_speed  = idle_image_speed;
    hsp = 0;

    if (attack_cooldown <= 0 && instance_exists(oPlayer))
        Boss2_DecideAction();
}

// ── WALK — mers sacadat spre player ─────────────────────
if (state == "walk")
{
    sprite_index = sBoss2Walk;
    var _dir = instance_exists(oPlayer) ? sign(oPlayer.x - x) : facing;
    hsp = _dir * walk_speed;
    // image_speed sincronizat cu viteza de mișcare — 8 FPS la walk normal
    image_speed  = (abs(hsp) / walk_speed) * 0.13;

    // Rezoluție orizontală
    if (place_meeting(x + hsp, y, oWall))
    {
        while (!place_meeting(x + sign(hsp), y, oWall))
            x += sign(hsp);
        hsp = 0;
    }
    else
        x += hsp;

    // Dacă e destul de aproape → idle și decide
    if (instance_exists(oPlayer))
    {
        var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);
        if (_dist < 120)
        {
            state = "idle";
            attack_cooldown = 20;
        }
    }
}

// ── WOLF OFFSCREEN — boss ascuns, așteaptă lupul ────────
if (state == "attack_wolf_offscreen")
{
    visible = false;
    hsp     = 0;

    if (wolf_done)
    {
        wolf_done = false;
        var _cam_x = camera_get_view_x(view_camera[0]);
        var _cam_w = camera_get_view_width(view_camera[0]);

        // Reapare pe partea OPUSĂ față de direcția lupului
        if (wolf_dir < 0) // lupul a ieșit stânga → boss reapare dreapta
        {
            x      = _cam_x + _cam_w + 80;
            facing = 1;  // privește spre stânga
        }
        else // lupul a ieșit dreapta → boss reapare stânga
        {
            x      = _cam_x - 80;
            facing = -1; // privește spre dreapta
        }
        visible = true;

        state        = "attack_wolf_reappear";
        sprite_index = sBoss2Walk;
        image_index  = 0;
        image_speed  = 0.18;
    }
}

// ── WOLF REAPPEAR — intră în scenă din dreapta ───────────
if (state == "attack_wolf_reappear")
{
    // Intră spre player (opus direcției lupului)
    hsp = -wolf_dir * walk_speed * 2;

    if (place_meeting(x + hsp, y, oWall))
    {
        while (!place_meeting(x - 1, y, oWall))
            x--;
        hsp = 0;
    }
    else
        x += hsp;

    // Odată ce e vizibil pe ecran → idle
    var _cam_x = camera_get_view_x(view_camera[0]);
    var _cam_w = camera_get_view_width(view_camera[0]);
    if (x < _cam_x + _cam_w - 80)
    {
        state = "idle";
        hsp   = 0;
        attack_cooldown = (phase == 2) ? 80 : 120;
        sprite_index    = sBoss2Idle;
        image_index     = 0;
        image_speed     = idle_image_speed;
    }
}

// ── ATTACK SCRIPTS ───────────────────────────────────────
if (state != "dizzy" && state != "dying" && state != "grave")
{
    Boss2_Phase1_Spit();
    Boss2_Phase2_Bats();
    Boss2_Phase3_Wolf();
}

// ── DYING ────────────────────────────────────────────────
if (state == "dying")
{
    if (animation_end())
    {
        state        = "grave";
        sprite_index = sBoss2Die;
        image_index  = sprite_get_number(sBoss2Die) - 1;
        image_speed  = 0;
    }
}

if (state == "grave")
{
    image_index = sprite_get_number(sBoss2Die) - 1;
    image_speed = 0;
}

prev_image_index = image_index;
