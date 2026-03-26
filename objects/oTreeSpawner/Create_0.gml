/// @description Spawner – plasezi pe PĂMÂNT (y = nivelul solului), copacul stă pe el
spawn_delay = 300;
spawn_timer = 0;
plant_x = x;
plant_y = y - 105;  // baza copacului – origin center, scale 3x
instance_create_layer(plant_x, plant_y, "Enemies", oTree);
