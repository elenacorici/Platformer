/// @func IeleHora()
/// Apelat din IeleUpdate cand iele_attack = "hora"
/// Faza 1: toate 3 se deplaseaza la pozitiile de formatie (una langa alta)
function IeleHora()
{
    // Odata ce oHora a preluat, Iela e invisibila — nu mai face nimic
    if (!visible) return;

    var _ctrl   = instance_exists(oBoss3Controller);
    var _target = _ctrl ? oBoss3Controller.scenario_target_x[my_index] : x;
    var _dist   = abs(x - _target);
    var _on_g   = place_meeting(x, y + 1, oWall);

    image_yscale = image_yscale_base;

    // Fizica verticala
    vsp += grv;
    if (place_meeting(x, y + vsp, oWall))
    {
        while (!place_meeting(x, y + sign(vsp), oWall)) y += sign(vsp);
        vsp = 0;
    }
    else y += vsp;
    y = floor(y);

    // Miscare spre pozitia de formatie
    if (_dist > 8)
    {
        facing       = (_target > x) ? 1 : -1;
        sprite_index = spr_skip;
        image_speed  = 0.18;
        image_xscale = -facing * image_xscale_base;
        hsp          = facing * 2.5;
    }
    else
    {
        // In pozitie — blocheaza x
        x   = _target;
        hsp = 0;

        var _hora_phase = _ctrl ? oBoss3Controller.hora_phase : 0;
        var _cx         = _ctrl ? oBoss3Controller.hora_center_x : x;

        if (_hora_phase >= 1)
        {
            // Toate pozitionate — porneste animatia de hora
            sprite_index = spr_hora;
            image_speed  = 0.15;
            // Toate privesc in aceeasi directie (spre dreapta)
            image_xscale = -image_xscale_base;
        }
        else
        {
            // Inca asteapta celelalte
            sprite_index = spr_idle;
            image_speed  = 0.12;
            image_xscale = (x < _cx) ? -image_xscale_base : image_xscale_base;
        }
    }

    // Coliziune orizontala
    if (hsp != 0)
    {
        if (place_meeting(x + hsp, y, oWall))
        {
            while (!place_meeting(x + sign(hsp), y, oWall)) x += sign(hsp);
            hsp = 0;
        }
        else x += hsp;
    }
}
