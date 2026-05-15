if (hit)
{
    speed = 0;
    if (animation_end())
        instance_destroy();
    exit;
}

// Gravitație ușoară — efect de boltă
vspeed += 0.12;
image_angle = point_direction(0, 0, hspeed, vspeed);

// Coliziune cu oWall
if (place_meeting(x, y, oWall))
{
    hit          = true;
    speed        = 0;
    sprite_index = spitP2;
    image_index  = 0;
    image_speed  = 0.2;
    image_angle  = 0;
    exit;
}

// Iese din room
if (x < -100 || x > room_width + 100 || y < -200 || y > room_height + 100)
    instance_destroy();
