// Outline lock-on — desenat INAINTE de sprite ca sa fie in spate
if (instance_exists(oPlayer) && oPlayer.bow_target == id)
{
    var _off = 4;
    for (var _d = 0; _d < 360; _d += 45)
        draw_sprite_ext(sprite_index, image_index,
            x + lengthdir_x(_off, _d),
            y + lengthdir_y(_off, _d),
            image_xscale, image_yscale, image_angle, c_yellow, 1);
}

if (state == ENEMYSTATE.ATTACK)
{
    draw_sprite_ext(sGhostIdleAttack_back, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);
    draw_self();
    if (flash > 0)
    {
        flash--;
        shader_set(shWhite);
        draw_sprite_ext(sGhostIdleAttack_back, image_index, x, y, image_xscale, image_yscale, 0, c_white, 1);
        draw_self();
        shader_reset();
    }
}
else
{
    draw_self();
    if (flash > 0)
    {
        flash--;
        shader_set(shWhite);
        draw_self();
        shader_reset();
    }
}
