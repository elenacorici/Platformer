/// @description Init oBatHang — atarnat static -> zboara la apropierea playerului
image_xscale=4;
image_yscale=4;

state = "hang";
sprite_index = bat;
image_index  = 0;   // frame 0 = liliacul cu capul in jos
image_speed  = 0;
depth        = -100; // in fata tileset-ului si wall-urilor, ca oBat

home_x = x;
home_y = y;

wake_range =90;   // cat de aproape trebuie sa fie playerul ca sa se trezeasca (super apropiat)
fly_speed  = 3;
fly_dir    = 0;

// Traiectorie simpla — suprascrie tot comportamentul normal (atarnat+trezire)
// daca e setata din Instance Creation Code. 0 = comportament normal (implicit),
// -1 = zboara doar la stanga, 1 = zboara doar la dreapta
trajectory = 0;
