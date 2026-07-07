if (is_stuck) exit;
if (other.invincible_timer > 0 || other.is_dead) exit;

var _dir = direction;

with (other) {
    hp              -= 1;
    flash            = 6;
    hitfrom          = (_dir < 90 || _dir > 270) ? 0 : 180;
    invincible_timer = 45;
}

instance_destroy();
