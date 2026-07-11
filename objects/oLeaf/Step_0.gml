if (!landed)
{
    // Leganare usoara stanga-dreapta, ca o frunza care flutura in cadere
    sway_timer += 1;
    hsp += sin(sway_timer * 0.05) * sway_amp * 0.02;

    vsp = min(vsp + grv, vsp_max);

    x += hsp;
    y += vsp;
    image_angle += spin_speed;

    if (y >= ground_y)
    {
        y            = ground_y;
        landed       = true;
        linger_timer = linger_total;
    }
}
else
{
    // Aterizata — nu se mai roteste/misca; sta cateva secunde, apoi se stinge
    linger_timer--;
    image_alpha = linger_timer / linger_total;
    if (linger_timer <= 0)
        instance_destroy();
}
