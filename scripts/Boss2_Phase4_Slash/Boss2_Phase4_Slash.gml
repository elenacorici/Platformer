/// @func Boss2_Phase4_Slash()
function Boss2_Phase4_Slash()
{
    if (state == "attack_slash")
    {
        var _fi = floor(image_index);
        var _fp = floor(prev_image_index);

        // Frame 4-6 — hitbox activ cu ghearele
        if (_fi >= 4 && _fi <= 6)
        {
            // Verifică player în fața boss-ului în raza de slash
            var _hx = x - facing * 60 * boss_scale;
            if (instance_exists(oPlayer)
                // y = tălpi → centrul boss la y - 80 (jumătate din 64px * 2.5)
                && point_distance(x, y - 80, oPlayer.x, oPlayer.y) < 80 * boss_scale
                && !slash_hit)
            {
                slash_hit = true;
                with (oPlayer)
                {
                    hp--;
                    hp    = max(0, hp);
                    flash = 3;
                    hitfrom = point_direction(other.x, other.y, x, y);
                }
            }
        }
        else
        {
            slash_hit = false;
        }

        if (animation_end())
        {
            state         = "attack_slash_recover";
            recover_timer = 100; // 1.7s window of opportunity (Regula 3)
            slash_hit     = false;
            sprite_index  = sBoss2Idle;
            image_index   = 0;
            image_speed   = idle_image_speed;
            hsp = 0;
        }
    }

    if (state == "attack_slash_recover")
    {
        recover_timer--;
        if (recover_timer <= 0)
        {
            state      = "walk";
            walk_timer = 90;
        }
    }
}
