/// @description actualizare camera

// Actualizare destinatie
if (instance_exists(follow))
{
    xTo = follow.x;
    yTo = follow.y;
}

// ── LETTERBOX tunel — crește pe măsură ce player avansează ──
if (room == rTunnel && instance_exists(oPlayer))
    letterbox_target = (oPlayer.x / room_width) * letterbox_max;
else
    letterbox_target = 0;
letterbox_current += (letterbox_target - letterbox_current) / 20;

// Actualizam pozitia obiectului
x += (xTo - x) / 25;
y += (yTo - y) / 25;

x = clamp(x, view_w_half + buff, room_width  - view_w_half - buff);
y = clamp(y, view_h_half + buff, room_height - view_h_half - buff);

x += random_range(-shake_remain, shake_remain);
y += random_range(-shake_remain, shake_remain);

shake_remain = max(0, shake_remain - ((1 / shake_length) * shake_magnitude));

// Actualizare camera view — round() elimină jitter-ul sub-pixel
camera_set_view_pos(cam, round(x - view_w_half), round(y - view_h_half));

// Parallax Backgrounds — rThree / rTunnel / BossRoom
if (layer_exists("Par1"))
    layer_x("Par1", x / 2);

if (layer_exists("Par2"))
    layer_x("Par2", x / 4);

if (layer_exists("Par3"))
    layer_x("Par3", x / 6);

// Parallax Backgrounds — rOne / rTwo
if (layer_exists("Mountains"))
    layer_x("Mountains", x / 2);   // cel mai din spate — mișcare mică

if (layer_exists("Trees2"))
    layer_x("Trees2", x / 4);      // mijloc

if (layer_exists("Trees"))
    layer_x("Trees", x / 6);       // cel mai din față — mișcare mare
