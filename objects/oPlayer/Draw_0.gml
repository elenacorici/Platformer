/// @description Ca oEnemy: clipire albă la damage + indicator lock-on

// Indicator lock-on — triunghi deasupra inamicului (outline-ul e in Draw_0 al inamicului)
if (bow_target != noone && instance_exists(bow_target)) {
	var _t  = bow_target;
	var _tx = _t.x;
	var _ty = _t.y - sprite_get_height(_t.sprite_index) * abs(_t.image_yscale) * 0.5 - 12;
	var _a  = 0.75 + sin(current_time / 200) * 0.25;
	draw_set_color(c_yellow);
	draw_set_alpha(_a);
	draw_triangle(_tx - 6, _ty, _tx + 6, _ty, _tx, _ty - 8, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

var _bow_hold = (state == PLAYERSTATE.ATTACK_BOW && bow_phase == "hold");
var _sx = x + 15 * image_xscale;
var _sy = y - 34;

// 1. Brat din SPATE — in spatele playerului
if (_bow_hold) {
	draw_sprite_ext(sBow_point_back, 0, _sx, _sy, 1, 1, bow_aim_dir + 180, c_white, 1);
}

// 2. Player body
draw_self();

// 3. Brat din FATA (arc) — in fata playerului
if (_bow_hold) {
	draw_sprite_ext(sBow_point, 0, _sx, _sy, 1, 1, bow_aim_dir + 180, c_white, 1);
}

// Flash alb la damage
if (flash > 0)
{
	flash--;
	shader_set(shWhite);
	draw_self();
	if (_bow_hold) {
		draw_sprite_ext(sBow_point_back, 0, _sx, _sy, 1, 1, bow_aim_dir + 180, c_white, 1);
		draw_sprite_ext(sBow_point, 0, _sx, _sy, 1, 1, bow_aim_dir + 180, c_white, 1);
	}
	shader_reset();
}
