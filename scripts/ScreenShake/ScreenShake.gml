/// @desc ScreenShake(magnitutde, frames)
/// @args Magnitude sets strength of shake(radius in pixels)
/// @args Frames sets length og the shake

function ScreenShake(){
	with(oCamera)
	{
		if(argument[0]> shake_remain)
		{
			shake_magnitude=argument[0];
			shake_remain= argument[0];
			shake_length=argument[1];
		}
	}

}