draw_self();

if (flash > 0)
{
	flash--;
	shader_set(shWhite);
	draw_self();
	shader_reset();
}

var bar_width = 100;
var _spr_h = sprite_get_height(sprite_index) * abs(image_yscale);
var bar_x = x - bar_width * 0.5;
var bar_y = y - _spr_h - 10;
var hp_percent = (max_hp > 0) ? clamp(hp / max_hp, 0, 1) : 0;

draw_set_color(c_red);
draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + 8, false);

draw_set_color(c_green);
draw_rectangle(bar_x, bar_y, bar_x + bar_width * hp_percent, bar_y + 8, false);

draw_set_color(c_white);
