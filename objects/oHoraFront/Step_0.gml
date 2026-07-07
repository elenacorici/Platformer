// Urmareste oHora si ii copiaza pozitia si frame-ul
if (!instance_exists(oHora))
{
    instance_destroy();
    exit;
}

x           = oHora.x;
y           = oHora.y;
image_index = oHora.image_index;
