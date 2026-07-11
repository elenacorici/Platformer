if (is_stuck) exit;
if (other.invincible_timer > 0 || other.is_dead) exit;
// Ielele nu pot fi lovite inainte sa inceapa fight-ul (intro/patrulare)
if (!instance_exists(oBoss3Controller) || !oBoss3Controller.fight_started) exit;

var _dir        = direction;
var _hit_target = other; // capturat INAINTE de with(other) — nu ne bazam pe "other" dupa with

with (other) {
    hp              -= 1;
    flash            = 6;
    hitfrom          = (_dir < 90 || _dir > 270) ? 0 : 180;
    invincible_timer = 45;
}

// Dupa ce lovesti target-ul cu arcul, se scoate automat lock-on-ul
if (instance_exists(oPlayer) && oPlayer.bow_target == _hit_target)
    oPlayer.bow_target = noone;

instance_destroy();
