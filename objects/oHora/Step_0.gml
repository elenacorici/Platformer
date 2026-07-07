if (!instance_exists(oPlayer)) exit;

// In intro, hora e vizuala — nu atrage si nu blocheaza playerul
if (instance_exists(oBoss3Controller) && !oBoss3Controller.fight_started) exit;

var _px   = oPlayer.x;
var _dist = abs(_px - x);

// ── PULL: atrage playerul spre centrul horei ──────────────────
if (!oPlayer.hora_stunned)
{
    if (_dist > 24)
    {
        oPlayer.hora_pull   = true;
        oPlayer.hora_pull_x = x;
    }
    else
    {
        // Player a ajuns — activeaza stun
        oPlayer.hora_pull       = false;
        oPlayer.hora_stunned    = true;
        oPlayer.hora_stun_timer = 180; // 3 sec la 60fps
    }
}

// ── STUN: numara si incheie hora ─────────────────────────────
if (oPlayer.hora_stunned)
{
    oPlayer.hora_stun_timer--;

    if (oPlayer.hora_stun_timer <= 0)
    {
        oPlayer.hora_stunned      = false;
        oPlayer.controls_inverted = true;
        oPlayer.invert_timer      = 240; // 4 secunde
        if (instance_exists(oBoss3Controller))
            oBoss3Controller._end_hora();
        instance_destroy();
    }
}
