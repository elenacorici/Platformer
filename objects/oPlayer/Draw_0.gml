/// @description Ca oEnemy: clipire albă la damage + indicator lock-on

// Indicator lock-on (world space, deasupra inamicului)
if (bow_target != noone && instance_exists(bow_target)) {
	var _t    = bow_target;
	var _tx   = _t.x;
	var _ty   = _t.y - sprite_get_height(_t.sprite_index) * abs(_t.image_yscale) * 0.5 - 12;
	var _a    = 0.75 + sin(current_time / 200) * 0.25; // pulsare
	var _off  = 3;
	var _col  = c_yellow;

	// Contur sprite: 8 offset-uri bright
	for (var _d = 0; _d < 360; _d += 45) {
		draw_sprite_ext(_t.sprite_index, _t.image_index,
			_t.x + lengthdir_x(_off, _d),
			_t.y + lengthdir_y(_off, _d),
			_t.image_xscale, _t.image_yscale,
			_t.image_angle, _col, 1);
	}

	// Triunghi mic pulsand deasupra
	draw_set_color(_col);
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
