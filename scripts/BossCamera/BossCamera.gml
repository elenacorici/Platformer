/// @func BossCamera_Update(_boss, _revealed, _reveal_x)
/// Actualizeaza cam_lock_x/cam_lock_w pentru un boss fight cu UN singur boss
/// (Boss1/Boss2 — pentru Boss3, cu 3 Iele simultan, algoritmul e diferit).
/// Apelat din oCamera.Step_0, cu self = oCamera.
/// _boss     = instanta boss-ului (folosita doar cat _revealed e true)
/// _revealed = true daca boss-ul e deja vizibil/in lupta; altfel camera
///             ramane fixa pe _reveal_x, ignorand playerul (efect dramatic
///             de reveal — playerul nu trebuie sa se vada in cadru)
/// _reveal_x = punctul fix pe care sta camera inainte ca boss-ul sa apara
function BossCamera_Update(_boss, _revealed, _reveal_x)
{
    if (!_revealed)
    {
        var _reveal_w    = 850; // ingust, dar nu prea mult (la 700 se stretch-uia vizibil) — ajusteaza
        var _reveal_half = _reveal_w * 0.5;
        // Clamp la limitele room-ului — fara asta, daca playerul se plimba (nu are
        // leash inainte de reveal) pana la marginea room-ului, camera il urmareste
        // direct acolo si arata dincolo de marginea room-ului (bug gasit de user)
        cam_lock_x = clamp(_reveal_x, _reveal_half + 32, room_width - _reveal_half - 32);
        cam_lock_w = _reveal_w;
        return;
    }

    // Bounding-box dinamic player+boss — vezi BossCamera_Leash pentru limitarea
    // distantei dintre ei, care tine de obicei latimea sub _min_w
    var _min_x = _boss.x;
    var _max_x = _boss.x;
    if (instance_exists(oPlayer))
    {
        _min_x = min(_min_x, oPlayer.x);
        _max_x = max(_max_x, oPlayer.x);
    }

    var _margin = 120;             // spatiu liber de fiecare parte a bounding-box-ului — ajusteaza
    var _min_w  = 1024;            // latimea implicita cand player+boss sunt apropiati — ajusteaza
    var _max_w  = room_width - 64; // safety net — nu trunchiaza niciodata sub necesar

    var _target_w  = clamp((_max_x - _min_x) + _margin * 2, _min_w, _max_w);
    var _target_cx = (_min_x + _max_x) * 0.5;
    var _half_w    = _target_w * 0.5;
    _target_cx = clamp(_target_cx, _half_w + 32, room_width - _half_w - 32);

    cam_lock_x = _target_cx;
    cam_lock_w = _target_w;
}

/// @func BossCamera_HoldStun(_revealed)
/// Tine playerul stunned CAT TIMP boss-ul nu s-a revelat (aceeasi conditie ca la
/// aparitia HP bar-ului si la BossCamera_Update) — inlocuieste stun_timer-ul fix
/// de 180 al trigger-ului, care nu tine cont de cat dureaza de fapt reveal-ul
/// (la Boss2 reveal-ul dureaza mult mai mult, lasand playerul liber sa se plimbe
/// — fara leash, care inca nu se aplica — pana la marginea room-ului).
/// Apelat din oCamera.Step_0, cu self = oCamera.
function BossCamera_HoldStun(_revealed)
{
    if (!instance_exists(oPlayer)) return;

    if (!_revealed)
    {
        // Nu stuna in aer — altfel, daca playerul e exact in saritura cand
        // pornim stun-ul, ramane inghetat suspendat (is_stunned forteaza vsp=0
        // in fiecare frame in oPlayer/Step_0, deci nu mai poate cadea deloc).
        // Asteapta sa aterizeze (contact cu solul) inainte sa aplice stun-ul.
        // FIX: place_meeting() foloseste masca instantei care APELEAZA functia
        // (self), nu a pozitiei pasate ca argument — apelat direct din oCamera
        // (fara sprite/masca proprie), verificarea testa masca lui oCamera, nu
        // a playerului, si era mereu falsa (de-asta "se pierdea" stun-ul complet,
        // in orice situatie, nu doar in aer). Cu with(oPlayer), verificarea
        // ruleaza cu self=oPlayer, folosind masca lui reala.
        var _player_grounded = false;
        with (oPlayer)
            _player_grounded = place_meeting(x, y + 1, oWall);

        if (_player_grounded)
        {
            oPlayer.is_stunned = true;
            oPlayer.stun_timer = 60; // reimprospatat in fiecare frame, valoarea exacta nu conteaza
        }
    }
    else if (oPlayer.is_stunned)
    {
        // Elibereaza imediat, exact in momentul in care boss-ul se reveleaza
        oPlayer.is_stunned = false;
        oPlayer.stun_timer = 0;
    }
}

/// @func BossCamera_Leash(_anchor_x, _leash)
/// Limiteaza distanta playerului fata de un punct-ancora ("da de zid" — hsp=0,
/// pozitie clamped) ca sa nu poata forta camera sa faca zoom out excesiv intr-un
/// room mare. Apelat din oCamera.Step_2 (End Step — trebuie sa ruleze DUPA
/// ce playerul isi rezolva miscarea normala, altfel risc de jitter).
/// _anchor_x = punctul fata de care se calculeaza distanta (ex. oBoss1.x, sau
///             centrul arenei la Boss3 — de-asta e un x brut, nu o instanta)
function BossCamera_Leash(_anchor_x, _leash)
{
    if (!instance_exists(oPlayer)) return;

    if (oPlayer.x > _anchor_x + _leash)
    {
        oPlayer.x = _anchor_x + _leash;
        if (oPlayer.hsp > 0) oPlayer.hsp = 0;
    }
    else if (oPlayer.x < _anchor_x - _leash)
    {
        oPlayer.x = _anchor_x - _leash;
        if (oPlayer.hsp < 0) oPlayer.hsp = 0;
    }
}
