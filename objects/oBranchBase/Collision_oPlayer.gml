if (other.state == PLAYERSTATE.ATTACK_SLASH || other.state == PLAYERSTATE.ATTACK_COMBO)
{
    // Înregistrează lovitură o singură dată per atac
    if (hit_cooldown <= 0)
    {
        hit_count++;
        hit_cooldown = 40;

        if (hit_count == 1)
        {
            // Prima lovitură — scuturare
            shake_timer = 25;
        }
        else if (hit_count >= 2 && state == "idle")
        {
            // A doua lovitură — ridică crengile
            state = "rise";
        }
    }
}
else if (state == "idle")
{
    // Body-ul player-ului atinge creanga — blochează
    with (other)
    {
        x -= hsp;
        hsp = 0;
    }
}
