/// @description Moștenește de la oEnemy dar folosește sprite Wolf pentru moarte

if(hp<=0)
{
	with(instance_create_layer(x,y,layer,oDead))
	{
		direction=other.hitfrom;
		hsp=lengthdir_x(2,direction); // Mai lent și la moarte
		vsp=lengthdir_y(2, direction)-2;
		// Lup desenat spre stânga: -sign(hsp) aliniază fața cu direcția împingerii
		if (sign(hsp) != 0)
			image_xscale = -sign(hsp) * 3;
		else
			image_xscale = 3;
		image_yscale=3;
		sprite_index=sWolfD; // Folosește sprite-ul de moarte Wolf
	}
	
	instance_destroy();
}
