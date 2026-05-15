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
                var _sx = x - facing * 20 * boss_scale;
                var _sy = y - 35 * boss_scale;
                instance_create_layer(_sx, _sy, "Bullets", oSpit);
            }
        }

        if (animation_end())
        {
            state         = "attack_spit_recover";
            recover_timer = 50;
            hsp = 0;
        }
    }

    if (state == "attack_spit_recover")
    {
        recover_timer--;
        if (recover_timer <= 0)
        {
            state        = "idle";
            sprite_index = sBoss2Idle;
            image_index  = 0;
            image_speed  = idle_image_speed;
            attack_cooldown = (phase == 2) ? 60 : 90;
        }
    }
}
