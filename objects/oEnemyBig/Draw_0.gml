draw_sprite_ext(sprite_index, image_index, x, y + wolf_draw_oy,
    image_xscale, image_yscale, image_angle, image_blend, image_alpha);

if (flash > 0)
{
    flash--;
    shader_set(shWhite);
    draw_sprite_ext(sprite_index, image_index, x, y + wolf_draw_oy,
        image_xscale, image_yscale, image_angle, image_blend, image_alpha);
    shader_reset();
}
