function PlayerState_Attack_Slash(){
	hsp=0;
	
	// Aplică gravitația și coliziunile verticale în timpul atacului
	// IMPORTANT: Verifică coliziunea cu mask-ul normal, nu cu hitbox-ul de atac
	var old_mask = mask_index;
	mask_index = -1; // Folosește mask-ul normal pentru coliziuni
	
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
		// Aplică mișcarea verticală doar dacă nu există coliziune
		y= y + vsp;
	}
	
//Start attack

if (sprite_index != sPlayerA1)
{
	sprite_index = sPlayerA1;
	image_index = 0;
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
					// Aplică damage (aceeași logică ca glonțul)
					hp--;
					flash = 3;
					hitfrom = other.attack_dir; // Folosește variabila de instanță a player-ului
				}
			}
		}
}
ds_list_destroy(hitByAttackNow);

if (keyAttack && image_index > 3 && combo_timer == 0)
	combo_timer = combo_window;
if (combo_timer > 0)
	combo_timer--;

if (animation_end())
{
	mask_index = -1;
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
	// Păstrează mask-ul de atac în timpul animației
	mask_index = sPlayerA1HB;
}

}