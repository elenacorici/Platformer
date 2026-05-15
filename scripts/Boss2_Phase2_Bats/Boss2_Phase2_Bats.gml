/// @func Boss2_Phase2_Bats()
function Boss2_Phase2_Bats()
{
    if (state == "attack_bats")
    {
        var _fi = floor(image_index);
        var _fp = floor(prev_image_index);

        // Frame 5 — spawneaza controller lilieci
        if (_fi == 5 && _fp != 5)
            instance_create_layer(x, y, "Enemies", oBatControl);

        if (animation_end())
        {
            state         = "attack_bats_recover";
            recover_timer = 40;
            hsp = 0;
        }
    }

    if (state == "attack_bats_recover")
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
