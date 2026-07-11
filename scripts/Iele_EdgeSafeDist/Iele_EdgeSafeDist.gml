/// @func Iele_EdgeSafeDist(_from_x, _dir, _dist, _arena_x1, _arena_x2, _margin)
/// Utilitar pur (fara dependinta de self/instance) — folosit de scenariile din
/// oBoss3Controller si de _iele_pick_orbit() din IeleUpdate.gml ca sa evite
/// "squish"-ul unei Iele langa zidul arenei (posibil chiar intre player si
/// zid, daca playerul e si el aproape de margine).
/// _dir: +1 = spre dreapta, -1 = spre stanga. Returneaza cea mai mare
/// distanta <= _dist care nu trece de zidul arenei in directia _dir.
function Iele_EdgeSafeDist(_from_x, _dir, _dist, _arena_x1, _arena_x2, _margin = 40)
{
    var _room = (_dir > 0) ? (_arena_x2 - _margin - _from_x) : (_from_x - _arena_x1 - _margin);
    return clamp(min(_dist, _room), 0, _dist);
}
