image_index  = 0;
image_speed  = 0;
image_xscale = 1.7;
image_yscale = 1.6;

y_start      = y;
y_risen      = y - 350;
y_tip        = y_risen + 80; // poziția finală — vârfurile rămân vizibile
rise_speed   = 12;
settle_speed = 2;
drop_speed   = 3;
state        = "idle";
shake_timer  = 0;
hit_count    = 0;
hit_cooldown = 0;
drop_delay      = 0;
was_triggered   = false;
