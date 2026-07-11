/// @description End Step — leash boss fight + wrap dash Iele (ruleaza DUPA
/// miscarea normala a playerului/Ielelor)
/// Logica comuna e in scripts/BossCamera.gml (BossCamera_Leash) si
/// scripts/Boss3Camera.gml (Boss3Camera_WrapDash) — aici doar decidem, per
/// room, cine e ancora si cand se aplica.

if (cam_locked)
{
    var _leash = 784; // cat de departe se poate indeparta playerul de boss — ajusteaza

    if (room == BossRoom_1 && instance_exists(oBoss1))
        BossCamera_Leash(oBoss1.x, _leash);
    else if (room == BossRoom2 && instance_exists(oBoss2) && string_pos("appearing", oBoss2.state) != 1)
        BossCamera_Leash(oBoss2.x, _leash);
}

// Boss3 (Iele) — separat de blocul de mai sus, pentru ca leash-ul pe centrul
// arenei trebuie activ INCLUSIV in faza de patrulare, ÎNAINTE ca camera sa
// se blocheze (cam_locked devine true abia cand Ielele s-au adunat)
if (room == BossRoom3 && instance_exists(oBoss3Controller))
{
    var _ctrl3 = oBoss3Controller;

    // Leash pe centrul arenei — activ de la trigger, cat timp hora #2 (atacul
    // de start, cu propriul pull/stun) inca nu a inceput. Raza e PROPORTIONALA
    // cu arena (jumatate din latime, minus o marja de 40px) — nu mai e
    // hardcodata la 700, care era calculata pentru room-ul vechi (2048 latime);
    // dupa ce arena a fost redusa la exact room-ul (1848), 700 lasa ~224px
    // inaccesibili pe fiecare margine — un "perete invizibil" simtit de user
    // exact langa marginile room-ului, desi arena_x1/x2 fusesera deja corectate.
    if (_ctrl3.intro_triggered && !_ctrl3.fight_started)
    {
        var _arena_cx3    = (_ctrl3.arena_x1 + _ctrl3.arena_x2) * 0.5;
        var _patrol_leash = (_ctrl3.arena_x2 - _ctrl3.arena_x1) * 0.5 - 40;
        BossCamera_Leash(_arena_cx3, _patrol_leash);
    }
    // Din momentul in care fight-ul a pornit efectiv, leash-ul trece pe Iela
    // cea mai indepartata de player (recalculat live) — vezi
    // Boss3Camera_LeashFarthest() pentru motiv (evita ca bounding-box-ul sa se
    // intinda la nesfarsit cat una din Iele sta lipita de player si alta e departe)
    else if (_ctrl3.fight_started)
    {
        Boss3Camera_LeashFarthest(848); // ajusteaza — +64 fata de leash-ul Boss1/2 (784)
    }

    // Ielele care dashuiesc pot iesi liber din cadru si reapar pe partea opusa
    if (cam_locked) Boss3Camera_WrapDash();
}
