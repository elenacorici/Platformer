image_speed  = 0.3;
image_xscale = 2.5;
image_yscale = 2.5;
depth        = -100; // în fața tileset-ului și wall-urilor

state      = "enter";
hp         = 1;
dead_timer = 0;

// Homing spre player în faza enter
velocity  = 4;
turnSpeed = 3;
direction = instance_exists(oPlayer)
    ? point_direction(x, y, oPlayer.x, oPlayer.y)
    : 180;

// Orbit
orbit_radius = 60 + random(60);   // 60-120px rază
orbit_angle  = random(360);        // unghi de start random
orbit_speed  = 4 + random(3);    // viteză unghi (grade/frame)
orbit_timer  = 40 + random(20);    // 0.7-1s de orbit — pleacă repede

// Damage cooldown — nu dă damage în fiecare frame
damage_cooldown = 90; // nu dă damage imediat la spawn — player are timp să reacționeze

// Exit
exit_speed = 6;
