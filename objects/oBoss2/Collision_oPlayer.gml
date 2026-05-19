// Contact damage — player trece prin boss dar primește damage
if (other.flash <= 0 && state != "dizzy" && state != "dying" && state != "grave")
{
    with (other)
    {
        hp--;
        hp      = max(0, hp);
        flash   = 60; // iframes — nu ia damage 1 secundă după contact
        hitfrom = point_direction(other.x, other.y, x, y);
    }
}
