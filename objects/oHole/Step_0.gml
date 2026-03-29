timer--;

// Fade out în ultimele 60 frames
if (timer < 60)
    image_alpha = timer / 60;

if (timer <= 0)
    instance_destroy();
