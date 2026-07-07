// Bolovanul
draw_self();

// Shadow pe sol — draw DUPA boulder ca sa fie dedesubt vizual la urmatorul frame
// shadow_y == -1 inseamna ca solul nu a fost gasit; nu desena umbra
if (shadow_y >= 0)
{
    var _dist  = max(0, shadow_y - y);
    var _alpha = clamp(1.0 - _dist / 500.0, 0.05, 0.5);
    var _rx    = clamp((1.0 - _dist / 500.0) * 22, 4, 22);

    draw_set_color(c_black);
    draw_set_alpha(_alpha);
    draw_ellipse(x - _rx * 1.7, shadow_y - _rx * 0.36,
                 x + _rx * 1.7, shadow_y + _rx * 0.36, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
