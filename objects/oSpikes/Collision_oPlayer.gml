// Acelasi tipar ca oLevelEnd/Collision_oPlayer.gml — hascontrol previne
// re-declansarea in fiecare frame cat playerul ramane suprapus cu spikes
with (oPlayer)
{
	if (hascontrol)
	{
		hascontrol = false;
		vsp = 0;
		hsp = 0;
		part_particles_create(p_sys, x, y - 24, p_hurt, 24);
		spike_hit_timer = 45; // ~0.75s la 60fps de blink rosu, apoi restart total (tasta R)
	}
}
