if(mode != TRANS_MODE.OFF)
 {
	 draw_set_color(c_black);
	 draw_rectangle(0,0,w,percent*h_half, false);
	 draw_rectangle(0,h,w,h-(percent*h_half), false);
	 
 }

// Inimi HP (desenate în același context ca tranziția)
if (instance_exists(oPlayer))
{
	var _p = oPlayer;
	var _hp = _p.hp_temp;
	var _shake = _p.heart_shake;
	var _max_hearts = _p.max_hearts;
	var _scale = 2.5;
	var _spacing = 36;

	for (var i = 0; i < _max_hearts; i++)
	{
		var _unit = _p.max_hp / _max_hearts;
		var full_value = (i + 1) * _unit;
		var half_value = i * _unit + _unit * 0.5;
		
		var heart_x = 12 + (i * _spacing);
		var heart_y = 12 + _shake;
		
		var _spr = sHeartEmpty;
		if (_hp >= full_value)
			_spr = sHeartFull;
		else if (_hp >= half_value)
			_spr = sHeartHalf;
		else
			_spr = sHeartEmpty;
		
		draw_sprite_ext(_spr, 0, heart_x, heart_y, _scale, _scale, 0, c_white, 1);
	}
}