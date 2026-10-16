/// MySQL / JSON often sends decimals as strings — never cast with `as num?`.
num? asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

double asDouble(dynamic v, [double fallback = 0]) => asNum(v)?.toDouble() ?? fallback;

int asInt(dynamic v, [int fallback = 0]) => asNum(v)?.toInt() ?? fallback;
