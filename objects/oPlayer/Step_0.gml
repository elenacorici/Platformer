 
// Finishing move — rulează indiferent de hascontrol
if (state == PLAYERSTATE.FINISHING_MOVE)
{
    PlayerState_FinishingMove();
    exit;
}

// Stun — player blocat complet
if (is_stunned) {
    stun_timer--;
    if (stun_timer <= 0)
        is_stunned = false;
    hsp = 0;
    vsp = 0;
}
else if(hascontrol) {
//Get Player Input
key_left=keyboard_check(vk_left) || keyboard_check(ord("A"));
key_right=keyboard_check(vk_right) || keyboard_check(ord("D"));
key_jump=keyboard_check(vk_space);
key_jump_pressed=keyboard_check_pressed(vk_space);
keyAttack       = mouse_check_button_pressed(mb_left);
key_sprint      = keyboard_check_pressed(ord("1"));
key_bow         = keyboard_check(ord("E"));
key_bow_pressed = keyboard_check_pressed(ord("E"));
key_lockon      = keyboard_check_pressed(ord("Q"));

// Switch armă cu B (doar dacă are arcul)
if (keyboard_check_pressed(ord("B")) && has_bow) {
    current_weapon = (current_weapon == "axe") ? "bow" : "axe";
}

// Lock-on cu Q (doar cu arcul echipat)
if (key_lockon && has_bow && current_weapon == "bow") {
    if (bow_target != noone) {
        bow_target = noone; // Q din nou = anuleaza
    } else {
        var _types = [oEnemy, oEnemyBig, oBoss1, oBoss2];
        var _nearest = noone;
        var _min_d   = 99999;
        for (var _i = 0; _i < array_length(_types); _i++) {
            var _inst = instance_nearest(x, y, _types[_i]);
            if (_inst != noone) {
                var _d = point_distance(x, y, _inst.x, _inst.y);
                if (_d < _min_d) { _min_d = _d; _nearest = _inst; }
            }
        }
        bow_target = _nearest;
    }
}

// Verifica daca target ul mai exista
if (bow_target != noone && !instance_exists(bow_target))
    bow_target = noone;

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
	case PLAYERSTATE.ATTACK_BOW:
		PlayerState_BowAttack();
		break;
}

		
}

else
{
	key_left=0;
	key_right=0;
	key_jump=0;
	key_jump_pressed=0;
}


// Scădere graduală HP (efect vizual)
if (hp_temp > hp)
	hp_temp = max(hp, hp_temp - 0.5);

// Shake inimi când se ia damage
if (hp_temp > hp && hp_temp > 0)
	heart_shake = random_range(-5, 5);
else
	heart_shake = 0;



