/// @description Lovitură jucător
with (other)
{
	if (variable_instance_exists(id, "hp"))
	{
		hp -= other.damage;
		hp = max(0, hp);
	}
}
instance_destroy();
