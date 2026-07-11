if (is_stuck) exit;

var _dmg        = arrow_dmg;
var _dir        = direction;
var _hit_target = other; // capturat INAINTE de with(other) — nu ne bazam pe "other" dupa with

with (other) {
	hp     -= _dmg;
	flash   = 3;
	hitfrom = (_dir < 90 || _dir > 270) ? 0 : 180;
}

// Dupa ce lovesti target-ul cu arcul, se scoate automat lock-on-ul
if (instance_exists(oPlayer) && oPlayer.bow_target == _hit_target)
    oPlayer.bow_target = noone;

instance_destroy();
