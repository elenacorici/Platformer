// Cooldown între lovituri
if (hit_cooldown > 0)
    hit_cooldown--;

// Animație de scuturare la lovire
if (shake_timer > 0)
{
    image_angle = sin(shake_timer * 0.3) * 3;
    shake_timer--;
    if (shake_timer <= 0)
        image_angle = 0;
}

// Rise complet după a 2-a lovitură
if (state == "rise")
{
    y -= rise_speed;
    if (y <= y_risen)
    {
        y = y_risen;
        state = "settle";
    }
}

// Coboară puțin — vârfurile rămân vizibile
if (state == "settle")
{
    y += settle_speed;
    if (y >= y_tip)
    {
        y = y_tip;
        state = "up";
    }
}

// Așteptare înainte de drop (efect de val)
if (state == "drop_wait")
{
    if (drop_delay > 0)
        drop_delay--;
    else
        state = "drop";
}

// Coboară din y_risen la y_start (perdea care cade)
if (state == "drop")
{
    y += drop_speed;
    if (y >= y_start)
    {
        y = y_start;
        state = "idle";
    }
}
