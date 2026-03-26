hsp=0;
vsp=0;
grv=0.1;
walksp=4;
hascontrol=true;
is_crouching = false;
was_crouching = false;
hp = 6;
max_hp = 6;
max_hearts = 3;
hp_temp = 6;   // pentru scădere graduală
heart_shake = 0;
flash = 0;
hitfrom = 0;

// Define enum before using it
enum PLAYERSTATE
{
	FREE,
	ATTACK_SLASH,
	ATTACK_COMBO	
}

state=PLAYERSTATE.FREE;
hitByAttack= ds_list_create();

// sPlayer e desenat spre stânga; convenția din cod: față spre dreapta => image_xscale -1
image_xscale = -1;

roll_dir = 1;
roll_timer = 0;
roll_duration = 60;
roll_speed = 5;

jumps_max = 2;
jumps_left = 2;

// Double jump — particule (stratul din cameră: „Player”, nu „Instances”)
p_sys = part_system_create_layer("Player", false);
p_dust = part_type_create();
part_type_shape(p_dust, pt_shape_pixel);
part_type_size(p_dust, 1, 3, -0.1, 0);
part_type_color2(p_dust, c_white, c_ltgray);
part_type_alpha2(p_dust, 1, 0);
part_type_speed(p_dust, 1, 3, -0.1, 0);
part_type_direction(p_dust, 0, 360, 0, 30);
part_type_gravity(p_dust, 0.2, 270);
part_type_life(p_dust, 15, 25);