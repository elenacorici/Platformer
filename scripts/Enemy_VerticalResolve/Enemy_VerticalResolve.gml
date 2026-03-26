/// @func Enemy_VerticalResolve()
/// @desc Coliziune verticală cu podea/tavan și aplică vsp pe y.
function Enemy_VerticalResolve()
{
	if (place_meeting(x, y + vsp, oWall))
	{
		while (!place_meeting(x, y + sign(vsp), oWall))
			y += sign(vsp);
		vsp = 0;
	}
	y += vsp;
}
