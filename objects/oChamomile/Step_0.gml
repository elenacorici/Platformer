y = y_base + sin((current_time / 400.0) + wave_offset) * 6;
image_angle += 0.8;
var _s = 3 + sin((current_time / 300.0) + wave_offset) * 0.4;
image_xscale = _s;
image_yscale = _s;
