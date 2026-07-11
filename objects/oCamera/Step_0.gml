/// @description actualizare camera

// F4 intra in fullscreen, Esc iesi din fullscreen
if (keyboard_check_pressed(vk_f4) && !window_get_fullscreen())
    window_set_fullscreen(true);
if (keyboard_check_pressed(vk_escape) && window_get_fullscreen())
    window_set_fullscreen(false);

// Boss3 (Iele) — camera se blocheaza abia dupa ce Ielele s-au adunat (nu in
// timpul patrularii haotice de perete-la-perete, care nu trebuie incadrata).
// Trebuie facut ÎNAINTE de blocul de mai jos, ca sa fie prins in acelasi frame.
if (room == BossRoom3 && instance_exists(oBoss3Controller)
&&  (oBoss3Controller.intro_step >= 2 || oBoss3Controller.fight_started))
    cam_locked = true;

// Fight-ul s-a terminat (Iela1 a iesit din ecran dupa fuga finala — win
// condition) — camera revine la comportamentul normal, urmarind liber
// playerul. Trebuie DUPA blocul de mai sus, ca sa castige (altfel
// fight_started ramane true si ar re-bloca camera in acelasi frame).
if (room == BossRoom3 && instance_exists(oBoss3Controller) && oBoss3Controller.fight_ended)
    cam_locked = false;

// ── Boss fight camera dinamica (bounding-box player+boss) ──────────────
// Logica comuna e in scripts/BossCamera.gml (BossCamera_Update/_Leash) pentru
// Boss1/Boss2, si scripts/Boss3Camera.gml (multi-target + wrap) pentru Boss3.
if (cam_locked)
{
    if (room == BossRoom_1)
    {
        var _revealed_1 = instance_exists(oBoss1);
        var _reveal_x_1 = instance_exists(oBossTree) ? oBossTree.x : room_width * 0.5;
        BossCamera_Update(oBoss1, _revealed_1, _reveal_x_1);
        BossCamera_HoldStun(_revealed_1);
    }
    else if (room == BossRoom2)
    {
        // oBoss2 e mereu plasat in room (invizibil) — "revelat" = a trecut de
        // starile de aparitie (appearing_wait/idle/bats), nu instance_exists
        var _revealed_2 = instance_exists(oBoss2) && string_pos("appearing", oBoss2.state) != 1;

        // Reveal in 3 faze (spre diferenta de Boss1, care sta tot timpul fix):
        // 1) de la trigger, cat joaca animatia mormantului + primele ~2.5 sec de ceata
        //    (oGrave.fog_done inca false, sau abia a devenit true) — camera fixa pe oGrave
        // 2) dupa ~2.5 sec de ceata, cat oBoss2 e inca invizibil (appearing_wait) —
        //    camera se muta spre player, inainte ca boss-ul sa devina vizibil
        // 3) de cand oBoss2 devine vizibil (appearing_idle = fade-in, appearing_bats =
        //    ridica mainile) — camera trece la bounding-box player+boss, ca playerul
        //    sa vada boss-ul aparand, desi fight-ul inca nu a pornit oficial
        //    (_revealed_2 — folosit pt HP bar/leash/stun — ramane neschimbat,
        //    devine true abia cand starea e efectiv "idle")
        var _since_fog     = (instance_exists(oBoss2) && oBoss2.appear_timer >= 0) ? (500 - oBoss2.appear_timer) : 0;
        var _boss_visible_2 = instance_exists(oBoss2) && (oBoss2.state == "appearing_idle" || oBoss2.state == "appearing_bats");
        var _show_boss_2    = _revealed_2 || _boss_visible_2;

        var _reveal_x_2;
        if (_since_fog >= 150) // ~2.5 secunde la 60fps — ajusteaza
            _reveal_x_2 = instance_exists(oPlayer) ? oPlayer.x : room_width * 0.5;
        else
            _reveal_x_2 = instance_exists(oGrave) ? oGrave.x : room_width * 0.5;

        BossCamera_Update(oBoss2, _show_boss_2, _reveal_x_2);
        BossCamera_HoldStun(_revealed_2);
    }
    else if (room == BossRoom3)
    {
        // Bounding-box multi-target (player + toate Ielele vii, exceptand cele
        // care dashuiesc) — activ din momentul in care Ielele s-au adunat
        // (vezi blocul de mai sus care seteaza cam_locked=true) si ramane activ
        // neschimbat pe tot parcursul: horă #1 → dialog → E → horă #2 (atac) →
        // dispersie.
        Boss3Camera_Update();

        // Player stunat (idle) din momentul in care Ielele se aliniaza pentru
        // hora #1 (intro_step==2) si pe tot parcursul dialogului (step 3) —
        // eliberat abia cand apasa E (fight_started=true), nu automat la
        // aparitia dialogului. Camera dinamica (bounding-box) arata alinierea
        // fara interferenta playerului.
        if (instance_exists(oBoss3Controller))
            BossCamera_HoldStun(oBoss3Controller.fight_started);
    }
}

// Actualizare destinatie
if (instance_exists(follow))
{
    // Y urmareste player-ul mereu
    yTo = follow.y - 36 + cam_y_offset;
    // X: liber cand nu e lock, fixat la centrul room-ului la lock
    if (!cam_locked)
        xTo = follow.x;
    else
        xTo = cam_lock_x;
}

// ── LETTERBOX tunel — crește pe măsură ce player avansează ──
if ((room == rTunnel || room == rTunnel_1 || room == rTunnel_2 || room == BossRoom || room == rThree_1) && instance_exists(oPlayer))
    letterbox_target = (oPlayer.x / room_width) * letterbox_max;
else
    letterbox_target = 0;
letterbox_current += (letterbox_target - letterbox_current) / 20;

// Actualizam pozitia obiectului
// La lock (boss fight), camera prinde tinta mai rapid — altfel "ramane in urma"
// playerului cat timp bounding-box-ul se schimba rapid intre player si boss
var _pos_ease = cam_locked ? 12 : 25;
x += (xTo - x) / _pos_ease;
y += (yTo - y) / _pos_ease;

// Tranzitie latime view spre cam_lock_w la lock (inaltimea ramane 720)
if (cam_locked)
{
    var _cur_w = camera_get_view_width(cam);
    var _new_w = lerp(_cur_w, cam_lock_w, 0.07);
    if (abs(_new_w - cam_lock_w) < 0.5) _new_w = cam_lock_w;
    _new_w = round(_new_w);
    camera_set_view_size(cam, _new_w, camera_get_view_height(cam));
    view_w_half = _new_w * 0.5;
}

// Clamp robust: daca room-ul e mai mic decat view-ul, centreaza camera
// La lock X e fixat (nu se face clamp pe X), Y urmareste player cu clamp normal
if (!cam_locked)
{
    var _cx_min = min(view_w_half + buff, room_width  * 0.5);
    var _cx_max = max(room_width  - view_w_half - buff, room_width  * 0.5);
    x = clamp(x, _cx_min, _cx_max);
}
var _cy_min = min(view_h_half + buff, room_height * 0.5);
var _cy_max = max(room_height - view_h_half - buff, room_height * 0.5);
y = clamp(y, _cy_min, _cy_max);

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

// Parallax Asset Layers — rRoom1 (case)
if (layer_exists("Assets_1"))
    layer_x("Assets_1", (x - view_w_half) * 0.12);

if (layer_exists("Assets_2"))
    layer_x("Assets_2", (x - view_w_half) * 0.22);


// Parallax Backgrounds — rOne / rTwo
if (layer_exists("Mountains"))
    layer_x("Mountains", x / 2);   // cel mai din spate — mișcare mică

if (layer_exists("Trees2"))
    layer_x("Trees2", x / 4);      // mijloc

if (layer_exists("Trees"))
    layer_x("Trees", x / 6);       // cel mai din față — mișcare mare
