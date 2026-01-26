/// @description Moștenește de la oEnemy dar folosește sprite Wolf pentru moarte

if(hp<=0)
{
	with(instance_create_layer(x,y,layer,oDead))
	{
		direction=other.hitfrom;
		hsp=lengthdir_x(2,direction); // Mai lent și la moarte
		vsp=lengthdir_y(2, direction)-2;
		if(sign(hsp)!=0) image_xscale=sign(hsp)*4; // Wolf mare - scalat vizual la 4x
		image_yscale=4;
		sprite_index=sWolfD; // Folosește sprite-ul de moarte Wolf
	}
	
	instance_destroy();
}
