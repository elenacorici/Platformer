/// @description Frunza care cade lin, plutind, si se aseaza pe sol

hsp = random_range(-1.0, 1.0);
vsp = random_range(0.3, 0.8);
grv = random_range(0.03, 0.06);
vsp_max = random_range(1.8, 2.4);

sway_timer = random_range(0, 100);
sway_amp   = random_range(0.3, 0.9);

spin_speed = random_range(-4, 4);

ground_y     = 867;
landed       = false;
linger_timer = -1;
linger_total = irandom_range(300, 480); // cateva secunde bune (60fps: 5-8s) inainte sa dispara

image_angle  = random(360);
image_speed  = 0;
image_xscale = random_range(0.85, 1.25);
image_yscale = image_xscale;
