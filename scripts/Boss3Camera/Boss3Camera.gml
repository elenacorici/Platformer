/// @func Boss3Camera_IsWrapEligible(_ie)
/// O Iela e "eligibila pentru wrap" (exclusa din bounding-box/leash + poate
/// iesi din cadru si reaparea pe partea opusa) cand NU e intr-un atac
/// coordonat (iele_attack=="none") SI NU e sub control de scenariu
/// (scenario_role=="idle") SI e suficient de departe de player.
///
/// FIXAT 2026-07-10 — bug gasit live: la dispersia dramatica din Phase 1
/// (_end_hora, Iela1/Iela2 dash spre marginile arenei via scenario_role=
/// "dash_to"), ambele deveneau wrap-eligibile (iele_attack=="none" + departe
/// de player) desi mergeau spre o TINTA precisa pe care playerul trebuie s-o
/// vada — camera nu se intindea sa le incapa, iar Boss3Camera_WrapDash() le
/// teleporta repetat pe marginea opusa a cadrului CURENT, creand un efect de
/// "sar intre 2 pozitii" perceput ca "2 seturi de Iela1/2" (Iela3, care merge
/// la creanga cu iele_attack=="perch", NU era afectata — de-asta bug-ul
/// aparea doar la 1 si 2, niciodata la 3). Fix: verificarea `scenario_role`
/// exclude explicit orice Iela aflata sub control activ de scenariu — doar
/// miscarea AMBIENTALA (personala, prin _iele_pick_orbit, scenario_role
/// mereu "idle" cat timp ruleaza) mai e eligibila pentru wrap.
///
/// Scenariile de "roi" (apropierea/schimb) o tin mereu <=260px de player,
/// deci raman mereu incluse indiferent de asta — doar excursiile ambientale
/// genuin lungi (skip/walk 320-380, traverse/flyover) trec pragul de distanta.
function Boss3Camera_IsWrapEligible(_ie)
{
    // Iela1, in secventa finala de fuga (escape_phase>0, dupa ce celelalte 2
    // au murit) — NICIODATA eligibila pentru wrap. E o miscare dedicata,
    // intr-o singura directie, spre iesirea din room (win condition) — daca
    // sistemul generic de wrap ar teleporta-o inapoi pe partea opusa a
    // cadrului (cum face normal cu orice Iela ambientala departe de player),
    // fuga ar bucla la infinit ("fuge, apoi se intoarce pe partea cealalta")
    // si fight_ended nu s-ar mai seta niciodata (x > room_width+150 nu s-ar
    // atinge vreodata).
    if (_ie.my_index == 0 && _ie.escape_phase > 0) return false;

    if (_ie.iele_attack != "none") return false;
    if (!instance_exists(oPlayer)) return false;
    if (!instance_exists(oBoss3Controller)) return false;
    var _ctrl = oBoss3Controller;
    if (_ctrl.scenario_role[_ie.my_index] != "idle") return false;

    var _wrap_dist = 350; // sub asta conteaza normal in cadru — ajusteaza
    if (abs(_ie.x - oPlayer.x) > _wrap_dist) return true;

    // FIXAT — "camera se intinde la infinit, Ielele nu mai pot iesi": criteriul
    // de mai sus (doar distanta fata de player) e usor de defectat daca
    // playerul RAMANE aproape de o Ielă care ambiental s-a dus spre zid (o
    // urmareste, sau chiar leash-ul de lupta o ancoreaza pe ea fiindca e "cea
    // mai indepartata" — vezi Boss3Camera_LeashFarthest) — distanta de 350
    // nu se atinge niciodata, deci ramane inclusa in bounding-box la infinit,
    // iar camera se intinde tot mai mult ca s-o incadreze, fara ca wrap-ul sa
    // se declanseze vreodata. Fix: eligibila SI daca e deja fizic aproape de
    // marginea arenei, indiferent unde e playerul — nu mai depinde doar de
    // distanta relativa.
    var _edge_zone = 60;
    if (_ie.x < _ctrl.arena_x1 + _edge_zone) return true;
    if (_ie.x > _ctrl.arena_x2 - _edge_zone) return true;

    return false;
}

/// @func Boss3Camera_Update()
/// Actualizeaza cam_lock_x/cam_lock_w pentru Boss3 (Iele) — bounding-box intre
/// player si toate Ielele vii eligibile (vezi Boss3Camera_IsWrapEligible).
/// Apelat din oCamera.Step_0, cu self = oCamera, doar cat timp cam_locked e
/// true (vezi dispatch-ul din Step_0).
function Boss3Camera_Update()
{
    if (!instance_exists(oBoss3Controller)) return;
    var _ctrl = oBoss3Controller;

    var _min_x = instance_exists(oPlayer) ? oPlayer.x : x;
    var _max_x = _min_x;

    for (var _i = 0; _i < 3; _i++)
    {
        var _ie = _ctrl.iele[_i];
        if (!instance_exists(_ie) || _ie.is_dead) continue;
        if (Boss3Camera_IsWrapEligible(_ie)) continue;

        _min_x = min(_min_x, _ie.x);
        _max_x = max(_max_x, _ie.x);
    }

    var _margin = 150;                              // spatiu liber de fiecare parte — ajusteaza
    var _min_w  = 1024;                              // latimea implicita — ajusteaza
    var _max_w  = _ctrl.arena_x2 - _ctrl.arena_x1;    // nu trunchiaza sub cat e nevoie in arena

    var _target_w  = clamp((_max_x - _min_x) + _margin * 2, _min_w, _max_w);
    var _target_cx = (_min_x + _max_x) * 0.5;
    var _half_w    = _target_w * 0.5;
    _target_cx = clamp(_target_cx, _ctrl.arena_x1 + _half_w, _ctrl.arena_x2 - _half_w);

    cam_lock_x = _target_cx;
    cam_lock_w = _target_w;
}

/// @func Boss3Camera_LeashFarthest(_leash)
/// Leash-ul playerului fata de Iela cea mai INDEPARTATA de player dintre cele
/// eligibile (recalculat in fiecare frame, FARA histerezis — o ancora "lipicioasa"
/// insemna ca, atunci cand Iela ancorata se apropie activ de player (nu prin
/// dash/wrap, ci mergand normal), leash-ul intarzia sa treaca pe cea reala mai
/// departe si playerul putea iesi din arena inainte ca switch-ul sa prinda din
/// urma). Ielele eligibile pentru wrap sunt EXCLUSE din calcul — altfel leash-ul
/// ar trage playerul spre o Iela care are voie sa fie in afara cadrului.
/// Apelat din oCamera.Step_2 (End Step), doar cat timp fight_started.
function Boss3Camera_LeashFarthest(_leash)
{
    if (!instance_exists(oBoss3Controller) || !instance_exists(oPlayer)) return;
    var _ctrl = oBoss3Controller;

    var _best_i = -1;
    var _best_d = -1;
    for (var _i = 0; _i < 3; _i++)
    {
        var _ie = _ctrl.iele[_i];
        if (!instance_exists(_ie) || _ie.is_dead) continue;
        if (Boss3Camera_IsWrapEligible(_ie)) continue;

        var _d = abs(_ie.x - oPlayer.x);
        if (_d > _best_d) { _best_d = _d; _best_i = _i; }
    }

    if (_best_i == -1) return; // toate Ielele vii sunt eligibile pentru wrap chiar acum — skip acest frame

    BossCamera_Leash(_ctrl.iele[_best_i].x, _leash);
}

/// @func Boss3Camera_WrapDash()
/// Orice Iela eligibila (vezi Boss3Camera_IsWrapEligible) care a iesit complet
/// din cadrul CURENT al camerei e teleportata pe marginea opusa, continuand
/// miscarea din partea cealalta — ca sa poata "traversa" ecranul fara sa fie
/// limitata de bounding-box-ul din Boss3Camera_Update(). Nu mai e limitat la
/// dash — orice excursie ambientala departe de player (walk/skip/traverse)
/// beneficiaza de acelasi tratament. Apelat din oCamera.Step_2 (End Step —
/// trebuie sa ruleze DUPA ce Ielele isi rezolva miscarea normala in IeleUpdate()).
function Boss3Camera_WrapDash()
{
    if (!instance_exists(oBoss3Controller)) return;
    var _ctrl   = oBoss3Controller;
    var _margin = 40; // cat de "afara" din cadru trebuie sa fie inainte sa fie teleportata — ajusteaza

    var _cam_left  = x - view_w_half - _margin;
    var _cam_right = x + view_w_half + _margin;

    // FIXAT — bug "2 seturi de Iele" recurent: destinatia teleportarii era
    // exact pragul de detectie al PARTII OPUSE (_cam_left/_cam_right, aceleasi
    // valori folosite mai sus ca sa decida "a iesit din cadru"). Camera isi
    // recalculeaza pozitia/latimea in fiecare frame (easing + bounding-box
    // care se schimba instant cand o Iela devine eligibila/neeligibila) — un
    // singur pixel de drift in directia gresita pe frame-ul URMATOR insemna ca
    // Ielea, abia teleportata, era din nou clasificata "iesita" si teleportata
    // inapoi — sarind intre cele 2 margini in bucla, perceput vizual ca "2
    // seturi" de Iele (era latent dinainte, dar Ielele ambientale (walk/skip)
    // nu ajungeau niciodata pana la pragul de wrap, blocate de zid — vezi
    // fix-ul de coliziune walk/skip din IeleUpdate.gml — de-aici a iesit la
    // iveala abia acum). Fix: aterizeaza cu o rezerva clara IN INTERIORUL
    // cadrului nou, nu exact pe prag, ca sa reziste la drift-ul normal al
    // camerei fara sa retrigger-uiasca imediat.
    var _land_buffer = 100;

    for (var _i = 0; _i < 3; _i++)
    {
        var _ie = _ctrl.iele[_i];
        if (!instance_exists(_ie) || _ie.is_dead) continue;
        if (!Boss3Camera_IsWrapEligible(_ie)) continue;

        if (_ie.x > _cam_right)
            _ie.x = clamp(_cam_left + _land_buffer, _ctrl.arena_x1, _ctrl.arena_x2);
        else if (_ie.x < _cam_left)
            _ie.x = clamp(_cam_right - _land_buffer, _ctrl.arena_x1, _ctrl.arena_x2);
    }
}
