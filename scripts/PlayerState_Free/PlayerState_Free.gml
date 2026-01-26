function PlayerState_Free(){
	//Calculate Movement
var move= key_right - key_left;
hsp=move * walksp;

vsp= vsp + grv;

// Verifică dacă player-ul este pe pământ (nu în coliziune verticală)
var on_ground = place_meeting(x, y+1, oWall);

if(on_ground && (key_jump))
{
	vsp=-3;
}

//Horizontal Collision
if(hsp != 0)
{
	// Verifică dacă player-ul este deja în coliziune
	var already_colliding = place_meeting(x, y, oWall);
	
	if(place_meeting(x+hsp,y,oWall))
	{
		// Dacă player-ul este deja în coliziune, verifică dacă se îndepărtează
		if(already_colliding)
		{
			// Verifică dacă după o mișcare mai mare player-ul va scăpa din coliziune
			// Dacă da, înseamnă că player-ul se îndepărtează de perete
			var test_pos = x + hsp * 2;
			if(!place_meeting(test_pos, y, oWall))
			{
				// Player-ul se îndepărtează de perete, permite mișcarea
				x = x + hsp;
			}
			else
			{
				// Ajustează poziția până când nu mai există coliziune
				while(!place_meeting(x+sign(hsp),y,oWall))
				{
					x=x+sign(hsp);
				}
				hsp=0;
			}
		}
		else
		{
			// Ajustează poziția până când nu mai există coliziune
			while(!place_meeting(x+sign(hsp),y,oWall))
			{
				x=x+sign(hsp);
			}
			hsp=0;
		}
	}
	else
	{
		x= x + hsp;
	}
}


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

//Animation
//If the Sprite is not on the ground, that means that its jumping
if(!place_meeting(x, y+1, oWall))
{
	image_speed=1;
	sprite_index= sPlayerJ;
}
//If the sprite its not jumping, its idling or walking
else
{
	image_speed=1
	if(sign(hsp)==0)
	{
		sprite_index=sPlayer;
	}
	else
	{	
		sprite_index= sPlayerR;
	}
}

if(sign(hsp)!=0)
{
	image_xscale=sign(hsp);
}

if(keyAttack) state = PLAYERSTATE.ATTACK_SLASH;
}