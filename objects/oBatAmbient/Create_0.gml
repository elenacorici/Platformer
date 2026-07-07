image_speed  = 0.25;
image_xscale = 2;
image_yscale = 2;
depth        = -900;

// Flock controller (activ doar cand e plasat in room fara viteza)
flock_timer   = irandom_range(60, 200);
flock_pending = 0;
flock_delay   = 0;
flock_dir     = 1;
y_offset      = 0; // suprascris din Creation Code daca vrei liliecii mai jos
