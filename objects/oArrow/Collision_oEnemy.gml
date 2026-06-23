var _dmg = arrow_dmg;
var _dir = direction;

with (other) {
	hp     -= _dmg;
	flash   = 3;
	hitfrom = (_dir < 90 || _dir > 270) ? 0 : 180;
}

speed    = 0;
is_stuck = true;
