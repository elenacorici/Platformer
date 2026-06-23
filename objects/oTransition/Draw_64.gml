if(mode != TRANS_MODE.OFF)
{
	draw_set_color(c_black);
	draw_rectangle(0,0,w,percent*h_half, false);
	draw_rectangle(0,h,w,h-(percent*h_half), false);
}

if (instance_exists(oPlayer))
{
	var _p  = oPlayer;
	var _gw = display_get_gui_width();
	var _gh = display_get_gui_height();

	// --- VIGNETTE GRADIENT (desenat primul, HUD apare deasupra) ---
	var _top_h    = 70;   // inaltimea gradientului de sus
	var _bot_h    = 70;   // inaltimea gradientului de jos
	var _side_w   = 25;   // latimea gradientului lateral
	var _top_a    = 0.85; // opacitate maxima sus/jos
	var _side_a   = 0.30; // opacitate maxima lateral

	// Sus: negru opac sus → transparent jos
	draw_primitive_begin(pr_trianglestrip);
	draw_vertex_color(0,   0,       c_black, _top_a);
	draw_vertex_color(_gw, 0,       c_black, _top_a);
	draw_vertex_color(0,   _top_h,  c_black, 0);
	draw_vertex_color(_gw, _top_h,  c_black, 0);
	draw_primitive_end();

	// Jos: transparent sus → negru opac jos
	draw_primitive_begin(pr_trianglestrip);
	draw_vertex_color(0,   _gh - _bot_h, c_black, 0);
	draw_vertex_color(_gw, _gh - _bot_h, c_black, 0);
	draw_vertex_color(0,   _gh,          c_black, _top_a);
	draw_vertex_color(_gw, _gh,          c_black, _top_a);
	draw_primitive_end();

	// Stanga: negru la stanga → transparent spre dreapta
	draw_primitive_begin(pr_trianglestrip);
	draw_vertex_color(0,       0,   c_black, _side_a);
	draw_vertex_color(_side_w, 0,   c_black, 0);
	draw_vertex_color(0,       _gh, c_black, _side_a);
	draw_vertex_color(_side_w, _gh, c_black, 0);
	draw_primitive_end();

	// Dreapta: transparent spre stanga → negru la dreapta
	draw_primitive_begin(pr_trianglestrip);
	draw_vertex_color(_gw - _side_w, 0,   c_black, 0);
	draw_vertex_color(_gw,           0,   c_black, _side_a);
	draw_vertex_color(_gw - _side_w, _gh, c_black, 0);
	draw_vertex_color(_gw,           _gh, c_black, _side_a);
	draw_primitive_end();

	// --- INIMI HP ---
	var _hp         = _p.hp_temp;
	var _shake      = _p.heart_shake;
	var _max_hearts = _p.max_hearts;
	var _scale      = 2.5;
	var _spacing    = 50;
	var _b          = 10; // padding de la margine

	for (var i = 0; i < _max_hearts; i++)
	{
		var _unit      = _p.max_hp / _max_hearts;
		var full_value = (i + 1) * _unit;
		var half_value = i * _unit + _unit * 0.5;

		var heart_x = (12 + _b) + (i * _spacing);
		var heart_y = (12 + _b) + _shake;

		var _spr = sHeartEmpty;
		if (_hp >= full_value)
			_spr = sHeartFull;
		else if (_hp >= half_value)
			_spr = sHeartHalf;
		else
			_spr = sHeartEmpty;

		draw_sprite_ext(_spr, 0, heart_x, heart_y, _scale, _scale, 0, c_white, 1);
	}

	// --- SLOTURI HUD ---
	var _slot_scale = 1.5;
	var _slot_size  = 40 * _slot_scale;
	var _slot_gap   = 8;
	var _slot_x0    = (12 + _b) + _slot_size / 2;
	var _slot_y     = 78 + _b;
	var _icon_scale = 1.8;

	// Slot 1 - Health (musetel)
	var _sl1_x     = _slot_x0;
	var _sl1_frame = (_p.chamomile_count > 0) ? 1 : 0;
	draw_sprite_ext(sSlotHealth, _sl1_frame, _sl1_x, _slot_y, _slot_scale, _slot_scale, 0, c_white, 1);
	if (_p.chamomile_count > 0) {
		draw_sprite_ext(sChamomile, 0, _sl1_x, _slot_y, _icon_scale, _icon_scale, 0, c_white, 1);
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_color(c_white);
		draw_text(_sl1_x + 22, _slot_y + 24, string(_p.chamomile_count) + "/3");
	}

	// Slot 2 - Speed/Jump (opinci)
	var _sl2_x     = _slot_x0 + _slot_size + _slot_gap;
	var _sl2_frame = _p.has_opinci ? 1 : 0;
	var _sl2_alpha = (_p.has_opinci && _p.opinci_state == "cooldown") ? 0.35 : 1;
	draw_sprite_ext(sSlotSpeedorJump, _sl2_frame, _sl2_x, _slot_y, _slot_scale, _slot_scale, 0, c_white, _sl2_alpha);
	if (_p.has_opinci) {
		draw_sprite_ext(sBoots, 0, _sl2_x, _slot_y, 0.9, 0.9, 0, c_white, _sl2_alpha);
		if (_p.opinci_state == "active" || _p.opinci_state == "cooldown") {
			draw_set_halign(fa_right);
			draw_set_valign(fa_bottom);
			draw_set_color(c_white);
			draw_text(_sl2_x + 22, _slot_y + 24, string(ceil(_p.opinci_timer / 60)));
		}
	}

	// Slot 3 - Drawings
	var _sl3_x     = _slot_x0 + (_slot_size + _slot_gap) * 2;
	var _drawings  = variable_instance_exists(_p, "drawing_count") ? _p.drawing_count : 0;
	var _sl3_frame = (_drawings > 0) ? 1 : 0;
	draw_sprite_ext(sSlotDrawings, _sl3_frame, _sl3_x, _slot_y, _slot_scale, _slot_scale, 0, c_white, 1);
	if (_drawings > 0) {
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_color(c_white);
		draw_text(_sl3_x + 22, _slot_y + 24, string(_drawings) + "/3");
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
