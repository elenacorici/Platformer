vsp= vsp + grv;
//Nu pica de pe margini
if(grounded)&& (afraidOfHeights)&&(!place_meeting(x+hsp, y+1, oWall))
{
	hsp=-hsp;
}

//Horizontal Collision
if(place_meeting(x+hsp,y,oWall))
{
	while(!place_meeting(x+sign(hsp),y,oWall))
	{
		x=x+sign(hsp);
	}
	
	hsp=-hsp;
}
x= x + hsp;


//Vertical Collision
if(place_meeting(x,y+vsp,oWall))
{
	while(!place_meeting(x,y+sign(vsp),oWall))
	{
		y=y+sign(vsp);
	}
	
	vsp=0;
}
y= y + vsp;

//Animation
//If the Sprite is not on the ground, that means that its jumping
if(!place_meeting(x, y+1, oWall))
{
	grounded=false;
	image_speed=1;
	sprite_index=sEnemyJ;
}
//If the sprite its not jumping, its idling or walking
else
{
	grounded=true;
	image_speed=1
	if(sign(hsp)==0)
	{
		sprite_index=sEnemy;
	}
	else
	{	
		sprite_index= sEnemyR;
		
		
		
	}
}

if(sign(hsp)!=0)
		{
			image_xscale=sign(hsp)*size;
		}
		else
		{
			image_xscale=size;
		}
image_yscale=size;