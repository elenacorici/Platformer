y = y_base + sin((current_time / 400.0) + wave_offset) * 6;
image_angle = sin((current_time / 600.0) + wave_offset) * 15;
var _s = 1.5 + sin((current_time / 350.0) + wave_offset) * 0.2;
image_xscale = _s;
image_yscale = _s;
