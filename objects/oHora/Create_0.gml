sprite_index = sHora_back;
image_speed  = 0.15;
image_xscale = 2.8;
image_yscale = 1.7;
depth        = 600; // in spatele playerului

// Creeaza layer-ul din fata (sandwich)
instance_create_layer(x, y, "Enemies", oHoraFront);
