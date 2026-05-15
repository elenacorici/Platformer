with (other)
{
    hp     -= 2;
    hp      = max(0, hp);
    flash   = 3;
    hitfrom = point_direction(other.x, other.y, x, y);
}
