 
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

    // Blocat vizual in idle — altfel ramane cu orice animatie rula inainte de stun
    // (ex. mers), dand impresia ca "merge pe loc" desi hsp/vsp sunt 0
    var _spr_idle_stun = (current_weapon == "bow") ? sPlayerBowI : sPlayerI;
    if (sprite_index != _spr_idle_stun)
    {
        sprite_index = _spr_idle_stun;
        image_index  = 0;
    }
    image_speed = 0.08;
}
else if(hascontrol) {
//Get Player Input
var _raw_left  = keyboard_check(vk_left)  || keyboard_check(ord("A"));
var _raw_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
key_left  = controls_inverted ? _raw_right : _raw_left;
key_right = controls_inverted ? _raw_left  : _raw_right;
key_jump=keyboard_check(vk_space);
key_jump_pressed=keyboard_check_pressed(vk_space);
keyAttack       = keyboard_check_pressed(ord("Z"));
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
        var _types = [oEnemy, oEnemyBig, oBoss1, oBoss2, oBoss31, oBoss32, oBoss33];
        var _iele_fight_on = instance_exists(oBoss3Controller) && oBoss3Controller.fight_started;
        var _nearest = noone;
        var _min_d   = 99999;
        for (var _i = 0; _i < array_length(_types); _i++) {
            var _inst = instance_nearest(x, y, _types[_i]);
            if (_inst != noone) {
                // Ielele nu pot fi targetate inainte sa inceapa fight-ul (intro/
                // patrulare) — la fel ca la damage.
                if ((_types[_i] == oBoss31 || _types[_i] == oBoss32 || _types[_i] == oBoss33)
                &&  !_iele_fight_on) continue;
                // Ielele moarte raman ca instante (invizibile, nu se distrug) —
                // nu trebuie sa poata fi targetate. Celelalte tipuri (oEnemy/
                // oBoss1/oBoss2) nu au deloc variabila is_dead, de-aici verificarea
                // cu variable_instance_exists inainte de a o citi.
                if (variable_instance_exists(_inst, "is_dead") && _inst.is_dead) continue;
                var _d = point_distance(x, y, _inst.x, _inst.y);
                if (_d < _min_d) { _min_d = _d; _nearest = _inst; }
            }
        }
        bow_target = _nearest;
    }
}

// Verifica daca target ul mai exista (sau a murit intre timp — Ielele nu se
// distrug la moarte, doar devin invizibile, deci instance_exists nu ar prinde asta)
if (bow_target != noone
&&  (!instance_exists(bow_target)
||   (variable_instance_exists(bow_target, "is_dead") && bow_target.is_dead)))
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
	case PLAYERSTATE.CLIMBING:
		PlayerState_Climbing();
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



