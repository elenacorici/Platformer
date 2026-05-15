/// @func Boss2_Phase3_Wolf()
function Boss2_Phase3_Wolf()
{
    if (state == "attack_wolf_spin")
    {
        hsp = 0;

        if (animation_end())
        {
            // Spawn lup — aleargă spre player
            var _w   = instance_create_layer(x, y, "Enemies", oWolf);
            var _dir = instance_exists(oPlayer) ? sign(oPlayer.x - x) : -1;
            _w.hspeed      = _dir * 9;
            _w.image_xscale = _dir * 2.5; // față spre player
            _w.wolf_dir    = _dir;         // salvat pentru boss reapariție

            // Boss dispare — va reapărea din dreapta când lupul iese
            visible = false;
            state   = "attack_wolf_offscreen";
        }
    }
}
