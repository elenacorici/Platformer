hsp=0;
vsp=0;
grv=0.1;
walksp=4;
hascontrol=true;
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