/// @func Boss2_Phase1_Spit()
function Boss2_Phase1_Spit()
{
    if (state == "attack_spit")
    {
        var _fi = floor(image_index);
        var _fp = floor(prev_image_index);

        // Frame 8 — lansează proiectilul spre player (range attack)
        if (_fi == 8 && _fp != 8)
        {
            if (instance_exists(oPlayer))
            {
                // Spawn la gura Strigoiului (față, la înălțimea capului)
                // y = tălpi → gura la ~10px de sus din sprite (71px) la scale 2.5
                var _sx = x - facing * 20 * boss_scale;
                var _sy = y - (71 - 10) * boss_scale; // y - 152
                instance_create_layer(_sx, _sy, "Bullets", oSpit);
            }
        }

        if (animation_end())
        {
            state         = "attack_spit_recover";
            recover_timer = 100; // 1.7s window of opportunity (Regula 3)
            sprite_index  = sBoss2Idle;
            image_index   = 0;
            image_speed   = idle_image_speed;
            hsp = 0;
        }
    }

    if (state == "attack_spit_recover")
    {
        recover_timer--;
        if (recover_timer <= 0)
        {
            // Merge 90f înainte să decidă — ritm 1-2-1-2 (Regula 2)
            state      = "walk";
            walk_timer = 90;
        }
    }
}
