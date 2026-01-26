hsp=0;
vsp=0;
grv=0.1;
walksp=4;
hascontrol=true;

// Define enum before using it
enum PLAYERSTATE
{
	FREE,
	ATTACK_SLASH,
	ATTACK_COMBO	
}

state=PLAYERSTATE.FREE;
hitByAttack= ds_list_create();