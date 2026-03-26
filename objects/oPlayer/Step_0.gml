 
if(hascontrol) {
//Get Player Input
key_left=keyboard_check(vk_left) || keyboard_check(ord("A"));
key_right=keyboard_check(vk_right) || keyboard_check(ord("D"));
key_jump=keyboard_check(vk_space);
keyAttack = mouse_check_button_pressed(mb_left); // Input pentru atac

switch (state)
{
	case PLAYERSTATE.FREE:
		PlayerState_Free();
		break;
	case PLAYERSTATE.ATTACK_SLASH:
		PlayerState_Attack_Slash();
		break;
	case PLAYERSTATE.ATTACK_COMBO:
		PlayerState_Attack_Combo();
		break;
	
}

		
}

else
{
	key_left=0;
	key_right=0;
	key_jump=0;
}

// Scădere graduală HP (efect vizual)
if (hp_temp > hp)
	hp_temp = max(hp, hp_temp - 0.5);

// Shake inimi când se ia damage
if (hp_temp > hp && hp_temp > 0)
	heart_shake = random_range(-5, 5);
else
	heart_shake = 0;



