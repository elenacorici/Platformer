if (is_stuck) exit;

var _dmg = arrow_dmg;
var _dir = direction;

with (other) {
	hp     -= _dmg;
	flash   = 3;
	hitfrom = (_dir < 90 || _dir > 270) ? 0 : 180;
}

x += lengthdir_x(28, direction);
y += lengthdir_y(28, direction);

speed          = 0;
is_stuck       = true;
stuck_angle    = direction;
stuck_target   = other.id;
stuck_offset_x = x - other.x;
stuck_offset_y = y - other.y;
