// ── APARIȚIE ─────────────────────────────────────────────────────────────
if (string_pos("appearing", state) == 1)
{
    vsp += grv;
    Enemy_VerticalResolve();
    image_xscale = facing * boss_scale;
    image_yscale = boss_scale;

    // Faza 1: invizibil, asteapta semnalul de la oGrave
    if (state == "appearing_wait")
    {
        if (instance_exists(oGrave) && oGrave.fog_done && appear_timer < 0)
            appear_timer = 500;

        if (appear_timer >= 0)
        {
            appear_timer--;
            if (appear_timer <= 0)
            {
                visible      = true;
                state        = "appearing_idle";
                sprite_index = sBoss2Idle;
                image_index  = 0;
                image_speed  = idle_image_speed;
                settle_timer = 120; // era 500 (~8.3s) — trece prea incet la ridicatul mainilor — ajusteaza
                if (instance_exists(oPlayer))
                    facing = -sign(oPlayer.x - x);
            }
        }
    }

    // Faza 2: fade in in ceata, stationeaza
    if (state == "appearing_idle")
    {
        image_alpha   = min(1, image_alpha + 1/60);
        settle_timer--;
        if (settle_timer <= 0)
        {
            state            = "appearing_bats";
            sprite_index     = sBoss2Attack2;
            image_index      = 0;
            image_speed      = 0.1;
            prev_image_index = 0;
        }
    }

    // Faza 3: animatia cu lilieci fara sa apara lilieci
    if (state == "appearing_bats")
    {
        image_alpha = 1;
        if (animation_end())
        {
            state           = "idle";
            sprite_index    = sBoss2Idle;
            image_index     = 0;
            image_speed     = idle_image_speed;
            attack_cooldown = 180;
        }
    }

    exit;
}

vsp += grv;
Enemy_VerticalResolve();

// Facing spre player — doar în walk și idle
if (instance_exists(oPlayer)
    && (state == "walk" || state == "idle"))
{
    var _dir = sign(oPlayer.x - x);
    if (_dir != 0) facing = -_dir;
}

image_xscale = facing * boss_scale;
image_yscale = boss_scale;


// Actualizare fază
if (instance_exists(oPlayer))
    phase = (hp > max_hp / 2) ? 1 : 2;

// ── TEST — E pornește finishing move indiferent de viață ────
if (keyboard_check_pressed(ord("E")) && instance_exists(oPlayer)
    && state != "dying" && state != "grave"
    && oPlayer.state != PLAYERSTATE.FINISHING_MOVE)
{
    var _p = oPlayer;
    if (point_distance(x, y, _p.x, _p.y) < 400)
    {
        // Forțează dizzy
        hp           = 1;
        state        = "dizzy";
        sprite_index = sBoss2Dizzy;
        image_index  = 0;
        image_speed  = 0.25;
        hsp          = 0;
        attack_cooldown = 99999;

        var _dir = sign(x - _p.x);
        _p.state         = PLAYERSTATE.FINISHING_MOVE;
        _p.hascontrol    = false;
        _p.fm_phase      = 0;
        _p.fm_boss       = id;
        _p.fm_dir        = _dir;
        _p.fm_prev_frame = 0;
        _p.fm_target_x   = x - 141 * _dir;
        _p.hsp           = 0;
        _p.vsp           = 0;
        _p.depth         = -200;
        _p.image_xscale  = (_dir > 0) ? 1 : -1;

        if (instance_exists(oCamera))
        {
            oCamera.follow = noone;
            oCamera.xTo    = (x + _p.x) * 0.5;
            oCamera.yTo    = y;
        }
    }
}

// Cooldown-uri
if (attack_cooldown > 0) attack_cooldown--;
if (spit_cooldown   > 0) spit_cooldown--;
if (bats_cooldown   > 0) bats_cooldown--;
if (wolf_cooldown   > 0) wolf_cooldown--;
if (slash_cooldown  > 0) slash_cooldown--;
if (flash           > 0) flash--;

// ── DIZZY — boss se clatină, nu mai atacă ────────────────
if (state == "dizzy")
{
    hsp = 0;

    // E apăsat aproape de boss → declanșează finishing move
    if (keyboard_check_pressed(ord("E")) && instance_exists(oPlayer))
    {
        var _p = oPlayer;
        if (point_distance(x, y, _p.x, _p.y) < 250)
        {
            var _dir = sign(x - _p.x); // direcția de la player spre boss

            // Inițializează finishing move — player merge înapoi mai întâi
            _p.state         = PLAYERSTATE.FINISHING_MOVE;
            _p.hascontrol    = false;
            _p.fm_phase      = 0; // faza 0 = walk back
            _p.fm_boss       = id;
            _p.fm_dir        = _dir;
            _p.fm_prev_frame = 0;
            _p.fm_target_x   = x - 141 * _dir; // distanța corectă pentru P2
            _p.hsp           = 0;
            _p.vsp           = 0;
            _p.y            += 6; // corectie vizuala walk-back
            _p.depth         = -200; // în fața boss-ului

            // Camera se blochează între player și boss
            if (instance_exists(oCamera))
            {
                oCamera.follow = noone;
                oCamera.xTo    = (x + _p.x) * 0.5;
                oCamera.yTo    = y;
            }
        }
    }

    // Ultimul hit — pornește animația de moarte
    if (hp <= 0)
    {
        state        = "dying";
        sprite_index = sBoss2Die;
        image_index  = 0;
        image_speed  = 0.1;
        image_angle  = 0;
        hsp          = 0;
    }

    exit;
}

// ── IDLE ────────────────────────────────────────────────
if (state == "idle")
{
    sprite_index = sBoss2Idle;
    image_speed  = idle_image_speed;
    hsp = 0;

    if (attack_cooldown <= 0 && instance_exists(oPlayer))
        Boss2_DecideAction();
}

// ── WALK — mers spre player cu timer ────────────────────
if (state == "walk")
{
    sprite_index = sBoss2Walk;
    var _dir = instance_exists(oPlayer) ? sign(oPlayer.x - x) : facing;

    if (walk_dir_cooldown > 0)
        walk_dir_cooldown--;

    // Schimbă direcția doar dacă cooldown-ul a expirat
    var _current_dir = sign(hsp);
    if (_current_dir != 0 && _dir != _current_dir && walk_dir_cooldown <= 0)
        walk_dir_cooldown = 60; // 1 secundă înainte să se întoarcă

    var _effective_dir = (walk_dir_cooldown > 0) ? _current_dir : _dir;
    hsp = lerp(hsp, _effective_dir * walk_speed, 0.12);
    image_speed = (abs(hsp) / walk_speed) * 0.13;

    // Rezoluție orizontală
    if (place_meeting(x + hsp, y, oWall))
    {
        while (!place_meeting(x + sign(hsp), y, oWall))
            x += sign(hsp);
        hsp = 0;
    }
    else
        x += hsp;

    // Countdown walk_timer → când expiră trece la idle
    walk_timer--;
    if (walk_timer <= 0)
    {
        state           = "idle";
        attack_cooldown = 0;
        hsp = 0;
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

// ── BLOCARE mișcare în orice stare de atac ───────────────
var _in_attack = (string_pos("attack_", state) == 1);
if (_in_attack) hsp = 0;

// ── ATTACK SCRIPTS ───────────────────────────────────────
if (state != "dizzy" && state != "dying" && state != "grave")
{
    Boss2_Phase1_Spit();
    Boss2_Phase2_Bats();
    Boss2_Phase3_Wolf();
    Boss2_Phase4_Slash();
}

// ── Tranzitii HP ─────────────────────────────────────────
if (state != "dizzy" && state != "dying" && state != "grave")
{
    // Trigger atac lup la hp <= 20 (o singura data)
    if (hp <= 20 && !wolf_triggered
    &&  state != "attack_wolf_spin" && state != "attack_wolf_offscreen" && state != "attack_wolf_reappear")
    {
        wolf_triggered   = true;
        state            = "attack_wolf_spin";
        sprite_index     = sBoss2Attack3P1;
        image_index      = 0;
        image_speed      = 0.2;
        prev_image_index = 0;
        last_attack      = "attack_wolf";
        hsp              = 0;
        wolf_dir         = instance_exists(oPlayer) ? sign(oPlayer.x - x) : -1;
    }
    // Dizzy la hp <= 10
    else if (hp <= 10)
    {
        hp              = 10;
        state           = "dizzy";
        sprite_index    = sBoss2Dizzy;
        image_index     = 0;
        image_speed     = 0.25;
        hsp             = 0;
        attack_cooldown = 99999;
    }
}

// ── Scale și flip corect pentru animația de moarte ───────
if (state == "dying" || state == "grave")
{
    image_xscale = -facing * 2.5;
    image_yscale = 2.5;
}

// ── DYING animation ───────────────────────────────────────
if (state == "dying")
{
    // Frame-urile 8-9 — dramatice și lente; de la 10 mai rapid
    var _fi = floor(image_index);
    if (_fi >= 8 && _fi <= 9)
        image_speed = 0.04; // dramatic
    else if (_fi >= 10)
        image_speed = 0.2;  // mai rapid dupa frame 10
    else if (image_speed != 0)
        image_speed = 0.1;  // normal

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
