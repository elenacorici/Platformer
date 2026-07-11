var _on_top = instance_exists(oPlayer)
           && place_meeting(x, y - 1, oPlayer)
           && oPlayer.vsp >= 0;

if (state == "idle")
{
    if (_on_top)
        timer++;
    else
        timer = 0;

    if (timer >= crack_delay)
    {
        state        = "cracking";
        sprite_index = cub_tile_crapat;
        image_index  = 0;
        image_speed  = 1;
    }
}

if (state == "cracking")
{
    var _progress = image_index / sprite_get_number(cub_tile_crapat);
    var _shake    = lerp(1, 3, _progress);
    x = ox + irandom_range(-_shake, _shake);

    if (image_index >= sprite_get_number(cub_tile_crapat) - 1)
    {
        state        = "collapsing";
        sprite_index = cub_tile_colaps;
        image_index  = 0;
        image_speed  = 1;
        x            = ox;
        // Mut tile-ul off-screen — place_meeting(oWall) nu il mai detecteaza
        // dar Draw event deseneaza animatia la (ox, oy)
        y            = -9999;
    }
}

if (state == "collapsing")
{
    if (image_index >= sprite_get_number(cub_tile_colaps) - 1)
        instance_destroy();
}
