/// @func Enemy_Step_Cooldowns()
function Enemy_Step_Cooldowns()
{
	if (attack_cooldown > 0)
		attack_cooldown--;
	if (idle_break_phase == 0 && idle_break_cooldown > 0)
		idle_break_cooldown--;
}
