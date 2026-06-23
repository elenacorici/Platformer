/// @description Ca oEnemy: clipire albă la damage

var _bow_hold = (state == PLAYERSTATE.ATTACK_BOW && bow_phase == "hold");
var _sx = x + 15 * image_xscale;
var _sy = y - 15 * image_yscale;

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
