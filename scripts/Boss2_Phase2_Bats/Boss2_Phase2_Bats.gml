/// @func Boss2_Phase2_Bats()
function Boss2_Phase2_Bats()
{
    if (state == "attack_bats")
    {
        hsp = 0; // stă pe loc în timpul invocării
        var _fi = floor(image_index);
        var _fp = floor(prev_image_index);

        // Frame 5 — spawneaza controller lilieci
        if (_fi == 5 && _fp != 5)
            instance_create_layer(x, y, "Enemies", oBatControl);

        if (animation_end())
        {
            state         = "attack_bats_recover";
            recover_timer = 150; // 2.5s — să dispară liliecii înainte de alt atac
            sprite_index  = sBoss2Idle;
            image_index   = 0;
            image_speed   = idle_image_speed;
            hsp = 0;
        }
    }

    if (state == "attack_bats_recover")
    {
        recover_timer--;
        if (recover_timer <= 0)
        {
            state      = "walk";
            walk_timer = 90;
        }
    }
}
