/// @func Boss2_Phase3_Wolf()
function Boss2_Phase3_Wolf()
{
    if (state == "attack_wolf_spin")
    {
        hsp = 0;

        if (animation_end())
        {
            // Spawn lup la nivelul solului
            var _dir  = instance_exists(oPlayer) ? sign(oPlayer.x - x) : -1;
            var _gy   = y;
            while (!place_meeting(x, _gy + 1, oWall) && _gy < room_height)
                _gy++;
            var _w = instance_create_layer(x, _gy, "Enemies", oWolf);
            _w.hspeed       = _dir * 9;
            _w.image_xscale = _dir * 2.5;
            _w.image_speed  = 0.3;
            _w.wolf_dir     = _dir;

            // Boss dispare — va reapărea din dreapta când lupul iese
            visible = false;
            state   = "attack_wolf_offscreen";
        }
    }
}
