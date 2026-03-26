/// @description Patrulare + animații lup (fără chase / atac).
vsp += grv;

hsp = patrol_move_speed * patrol_dir;
if (idle_break_phase != 0)
	hsp = 0;

Enemy_HorizontalResolve();
Enemy_VerticalResolve();
Wolf_UpdateLocomotionAnim();

var _v = (object_index == oWolfSmall) ? 3 : 4;
if (sign(hsp) != 0)
	image_xscale = -sign(hsp) * _v;
else
	image_xscale = -patrol_dir * _v;
image_yscale = _v;
