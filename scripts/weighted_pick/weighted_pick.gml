/// @func weighted_pick(actions, weights)
/// @desc Alege aleatoriu o acțiune bazat pe weight-uri. Weight mai mare = ales mai des.
/// @returns {string} acțiunea aleasă

function weighted_pick(actions, weights) {
    var total = 0;
    var n = array_length(weights);
    for (var i = 0; i < n; i++)
        total += weights[i];

    if (total <= 0) return actions[0]; // fallback

    var r = random(total);
    var cursor = 0;
    for (var i = 0; i < n; i++) {
        cursor += weights[i];
        if (cursor >= r) return actions[i];
    }
    return actions[n - 1];
}
