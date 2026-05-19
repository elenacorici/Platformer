switch (state)
{
    case "idle":
        // Numără cât timp player-ul stă aproape
        if (instance_exists(oPlayer) && distance_to_object(oPlayer) < 250)
            proximity_timer++;
        else
            proximity_timer = max(0, proximity_timer - 2);

        if (proximity_timer < proximity_needed)
            break;
        {
            state        = "wake";
            sprite_index = sBossTreeWake;
            image_index  = 0;
            image_speed  = 0.08;

            if (instance_exists(oCamera))
            {
                oCamera.follow = noone;
                oCamera.xTo    = x;
                oCamera.yTo    = y;
            }

            if (instance_exists(oPlayer))
                oPlayer.hascontrol = false;
        }
        break;

    case "wake":
        if (animation_end())
        {
            state        = "burst";
            sprite_index = sBossTreeBurst;
            image_index  = 0;
            image_speed  = 0.2;
            ScreenShake(5, 90);
        }
        break;

    case "burst":
        if (animation_end())
        {
            var _boss = instance_create_layer(x, y, "Enemies", oBoss1);
            _boss.state         = "idle";
            _boss.patrol_origin = x;

            if (instance_exists(oCamera))
                oCamera.follow = oPlayer;
            if (instance_exists(oPlayer))
                oPlayer.hascontrol = true;

            instance_destroy();
        }
        break;
}
