/// @description Draw GUI - inimi + sloturi HUD
if (!instance_exists(oPlayer)) exit;

var _p = oPlayer;
var _hp = _p.hp_temp;
var _shake = _p.heart_shake;
var _max_hearts = _p.max_hearts;
var _scale = 2.5;
var _spacing = 36;

// --- INIMI ---
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

// --- SLOTURI HUD ---
var _slot_scale = 1.5;
var _slot_size  = 40 * _slot_scale; // 60px
var _slot_gap   = 8;
var _slot_x0    = 12 + _slot_size / 2;
var _slot_y     = 78;
var _icon_scale = 1.8;

// Slot 1 - Health (musetel)
var _sl1_x    = _slot_x0;
var _sl1_frame = (_p.chamomile_count > 0) ? 1 : 0;
draw_sprite_ext(sSlotHealth, _sl1_frame, _sl1_x, _slot_y, _slot_scale, _slot_scale, 0, c_white, 1);
draw_sprite_ext(sChamomile, 0, _sl1_x, _slot_y, _icon_scale, _icon_scale, 0, c_white, 1);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
draw_text(_sl1_x + 22, _slot_y + 24, string(_p.chamomile_count) + "/3");

// Slot 2 - Speed/Jump (opinci - sprite urmeaza)
var _sl2_x = _slot_x0 + _slot_size + _slot_gap;
draw_sprite_ext(sSlotSpeedorJump, 0, _sl2_x, _slot_y, _slot_scale, _slot_scale, 0, c_white, 1);

// Slot 3 - Drawings
var _sl3_x    = _slot_x0 + (_slot_size + _slot_gap) * 2;
var _drawings  = variable_instance_exists(_p, "drawing_count") ? _p.drawing_count : 0;
var _sl3_frame = (_drawings > 0) ? 1 : 0;
draw_sprite_ext(sSlotDrawings, _sl3_frame, _sl3_x, _slot_y, _slot_scale, _slot_scale, 0, c_white, 1);
draw_text(_sl3_x + 22, _slot_y + 24, string(_drawings) + "/3");

// reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
