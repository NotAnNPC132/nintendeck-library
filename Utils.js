function assetOrEmpty(url) {
    return url ? url : "";
}

function clamp(value, min, max) {
    return Math.max(min, Math.min(max, value));
}

function formatPlayTime(seconds) {
    if (!seconds || seconds <= 0) return "Never played";
    var h = Math.floor(seconds / 3600);
    var m = Math.floor((seconds % 3600) / 60);
    if (h > 0) return h + "h " + m + "m";
    return m + "m";
}

function formatDate(date) {
    if (!date || isNaN(date.getTime())) return "";
    var y = date.getFullYear();
    var mo = ("0" + (date.getMonth() + 1)).slice(-2);
    var d = ("0" + date.getDate()).slice(-2);
    return y + "-" + mo + "-" + d;
}

function formatRating(rating) {
    var stars = Math.round(rating * 5);
    var out = "";
    for (var i = 0; i < 5; i++) out += (i < stars) ? "★" : "☆";
    return out;
}

function normalizeForSearch(text) {
    if (!text) return "";
    return text.toLowerCase()
               .replace(/[áàäâã]/g, "a")
               .replace(/[éèëê]/g,  "e")
               .replace(/[íìïî]/g,  "i")
               .replace(/[óòöôõ]/g, "o")
               .replace(/[úùüû]/g,  "u")
               .replace(/[ñ]/g,     "n")
               .replace(/[ç]/g,     "c")
               .trim();
}

function gameMatchesSearch(game, query) {
    if (!query || query.length === 0) return true;
    var fields = [
        game.title     || "",
        game.developer || "",
        game.publisher || "",
        game.genre     || ""
    ];
    for (var i = 0; i < fields.length; i++) {
        if (normalizeForSearch(fields[i]).indexOf(query) !== -1)
            return true;
    }
    return false;
}
