/// @description Folosește sprite-uri Wolf - copiază logica din oEnemy Step_0

vsp= vsp + grv;
//Nu pica de pe margini - Wolf e 4x mai mare, verifică la ~jumătate din lățime (60 px)
var check_distance = 60; // Distanță fixă pentru labele din față
if(grounded)&& (afraidOfHeights)&&(!place_meeting(x + check_distance * sign(hsp), y+1, oWall))
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

//Animation - WOLF SPRITES
//If the Sprite is not on the ground, that means that its jumping
if(!place_meeting(x, y+1, oWall))
{
	grounded=false;
	image_speed=0.25; // Animație mult mai lentă
	sprite_index=sWolfR; // Wolf nu are jump sprite, folosește running
}
//If the sprite its not jumping, its idling or walking
else
{
	grounded=true;
	image_speed=0.25; // Animație mult mai lentă
	if(sign(hsp)==0)
	{
		sprite_index=sWolf; // Wolf idle
	}
	else
	{	
		sprite_index=sWolfR; // Wolf running
	}
}

// Wolf-ul este mult mai mare vizual (4x) dar size=1 pentru coliziuni normale
if(sign(hsp)!=0)
{
	image_xscale=sign(hsp)*4; // Wolf mare - scalat vizual la 4x
}
else
{
	image_xscale=4;
}
image_yscale=4;
