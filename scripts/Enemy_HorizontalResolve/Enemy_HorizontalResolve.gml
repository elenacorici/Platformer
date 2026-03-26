/// @func Enemy_HorizontalResolve()
/// @desc afraidOfHeights, coliziune perete, aplică hsp pe x.
function Enemy_HorizontalResolve()
{
	// afraidOfHeights (nu întoarce la margine în timpul pauzei idle)
	var _edge_dir = (sign(hsp) != 0) ? sign(hsp) : patrol_dir;
	if (idle_break_phase == 0 && grounded && afraidOfHeights && !place_meeting(x + check_distance * _edge_dir, y + 1, oWall))
	{
		hsp = -hsp;
		patrol_dir = -patrol_dir;
	}
	
	// Coliziune orizontală
	if (place_meeting(x + hsp, y, oWall))
	{
		while (!place_meeting(x + sign(hsp), y, oWall))
			x += sign(hsp);
		hsp = -hsp;
		patrol_dir = -patrol_dir;
	}
	x += hsp;
}
