vsp         = 4;    // porneste cu viteza initiala — simte greutatea imediat
grv         = 0.7;  // acceleratie mai mare
has_hit     = false;
shadow_y    = y;
linger_timer = -1; // -1 = in cadere; >=0 = pe sol, numara pana la disparitie

image_xscale = 1.6;
image_yscale = 1.6;
image_angle  = irandom(3) * 90; // rotit in trepte de 90° — arata natural fara tumbling
image_index  = irandom(2);      // alege random din cele 3 frame-uri
image_speed  = 0;
