function PlayerState_Attack_Slash(){
	hsp=0;
	
	// Aplică gravitația și coliziunile verticale în timpul atacului
	// IMPORTANT: Verifică coliziunea cu mask-ul normal, nu cu hitbox-ul de atac
	var old_mask = mask_index;
	mask_index = sPlayer; // Folosește mask-ul normal pentru coliziuni
	
	vsp= vsp + grv;
	
	//Vertical Collision
	if(place_meeting(x,y+vsp,oWall))
	{
		while(!place_meeting(x,y+sign(vsp),oWall))
		{
			y=y+sign(vsp);
		}
		vsp=0;
	}
	else
	{
		y = y + vsp;
	}
	y = floor(y); // previne acumularea de y fractionar
	
//Start attack

if (sprite_index != sPlayerA1)
{
	sprite_index = sPlayerA1;
	image_index  = 0;
	image_speed  = 1;
	ds_list_clear(hitByAttack);
}

//Folosim un attack hitbox si verificam daca exista hits
mask_index= sPlayerA1HB; 
// Calculează direcția de atac (bazată pe direcția player-ului) - variabilă de instanță
// Aliniat cu sprite stânga + image_xscale = -sign(hsp)
attack_dir = image_xscale > 0 ? 180 : 0;

var hitByAttackNow=ds_list_create();
var hits= instance_place_list(x,y,oEnemy, hitByAttackNow,false);
hits += instance_place_list(x,y,oEnemyBig, hitByAttackNow,false);
hits += instance_place_list(x,y,oBoss1, hitByAttackNow,false);
hits += instance_place_list(x,y,oBoss2, hitByAttackNow,false);
hits += instance_place_list(x,y,oBat,   hitByAttackNow,false);
hits += instance_place_list(x,y,oBoss31, hitByAttackNow,false);
hits += instance_place_list(x,y,oBoss32, hitByAttackNow,false);
hits += instance_place_list(x,y,oBoss33, hitByAttackNow,false);
hits += instance_place_list(x,y,oBee,   hitByAttackNow,false);
if(hits>0)
{
		for(var i=0; i<hits; i++)
		{
			//Daca instanta nu a fost lovita
			var hitID= hitByAttackNow[|i];
			if(ds_list_find_index(hitByAttack,hitID)==-1)
			{
				ds_list_add(hitByAttack, hitID);
				with(hitID)
				{
					if (object_index == oBat)
					{
						// Liliac — pornește animația de moarte
						if (state != "dying" && state != "dead")
						{
							state        = "dying";
							sprite_index = bat_die;
							image_index  = 0;
							image_speed  = 0.25;
							hspeed       = 0;
							vspeed       = -2;
						}
					}
					else if (object_index == oBoss31 || object_index == oBoss32 || object_index == oBoss33)
					{
						var _fight_on = instance_exists(oBoss3Controller) && oBoss3Controller.fight_started;
						if (_fight_on && invincible_timer <= 0 && !is_dead)
						{
							hp -= 1;
							flash            = 6;
							hitfrom          = other.attack_dir;
							invincible_timer = 45;
						}
					}
					else if (object_index == oBee)
					{
						// Albina — moare dintr-un hit, ca liliacul (fara hp)
						if (state != "dying" && state != "dead")
						{
							state        = "dying";
							sprite_index = albinuta_death;
							image_index  = 0;
							image_speed  = 0.2;
							hspeed       = 0;
							vspeed       = -2;
						}
					}
					else
					{
						hp -= 10; // TEST
						flash   = 3;
						hitfrom = other.attack_dir;
					}
				}
			}
		}
}
ds_list_destroy(hitByAttackNow);

// Detectie Iele prin distanta (bbox sIele1Idle = 9px, prea ingust pt. hitbox overlap)
var _iele_range   = 80;
var _iele_obj     = [oBoss31, oBoss32, oBoss33];
var _iele_fight_on = instance_exists(oBoss3Controller) && oBoss3Controller.fight_started;
for (var _ii = 0; _ii < 3; _ii++)
{
    with (_iele_obj[_ii])
    {
        if (_iele_fight_on
        &&  !is_dead
        &&  ds_list_find_index(other.hitByAttack, id) == -1
        &&  point_distance(other.x, other.y, x, y) < _iele_range)
        {
            ds_list_add(other.hitByAttack, id);
            if (invincible_timer <= 0)
            {
                hp -= 1;
                flash    = 6;
                hitfrom  = other.attack_dir;
                invincible_timer = 45;
            }
        }
    }
}

if (keyAttack && image_index > 3 && combo_timer == 0)
	combo_timer = combo_window;
if (combo_timer > 0)
	combo_timer--;


if (animation_end())
{
	mask_index = sPlayer;
	if (combo_timer > 0)
	{
		combo_count = 1;
		combo_timer = 0;
		state = PLAYERSTATE.ATTACK_COMBO;
	}
	else
	{
		combo_count = 0;
		state = PLAYERSTATE.FREE;
	}
}
else
{
	mask_index = sPlayerA1HB;
}

}