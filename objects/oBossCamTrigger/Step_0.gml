/// @description Activeaza lock camera + porneste intro-ul de boss (mormant/copac) cand player-ul intra in zona
if (!instance_exists(oPlayer)) exit;
if (!instance_exists(oCamera)) exit;

if (abs(oPlayer.x - x) < trigger_half_w)
{
    // Lock camera pe X
    with (oCamera)
    {
        cam_locked = true;
        cam_lock_x = room_width * 0.5;
        cam_lock_w = 1024;
    }

    // Porneste animatia mormantului (BossRoom2)
    with (oGrave)
    {
        sprite_index = sGraveStart;
        image_index  = 0;
        image_speed  = 0.05;
    }

    // Porneste animatia de trezire a copacului (BossRoom_1)
    with (oBossTree)
    {
        state        = "wake";
        sprite_index = sBossTreeWake;
        image_index  = 0;
        image_speed  = 0.08;
    }

    // Stun player
    oPlayer.is_stunned = true;
    oPlayer.stun_timer = 180;

    instance_destroy();
}
