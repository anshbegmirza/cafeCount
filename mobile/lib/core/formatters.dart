import 'package:intl/intl.dart';

/// Asia/Kolkata is UTC+5:30 with no DST — fixed offset is enough for V1.
DateTime toKolkata(DateTime dt) => dt.toUtc().add(const Duration(hours: 5, minutes: 30));

DateTime kolkataNow() => toKolkata(DateTime.now());

/// e.g. `2h ago · 14 Oct, 5:56 PM`
String formatRelativeAbsolute(String? iso) {
  final parsed = DateTime.tryParse(iso ?? '');
  if (parsed == null) return iso?.isNotEmpty == true ? iso! : '—';

  final local = toKolkata(parsed);
  final now = kolkataNow();
  final diff = now.difference(local);

  final String relative;
  if (diff.isNegative || diff.inSeconds < 60) {
    relative = 'just now';
  } else if (diff.inMinutes < 60) {
    relative = '${diff.inMinutes}m ago';
  } else if (diff.inHours < 24) {
    relative = '${diff.inHours}h ago';
  } else if (diff.inDays < 7) {
    relative = '${diff.inDays}d ago';
  } else {
    relative = DateFormat('d MMM').format(local);
  }

  final absolute = DateFormat('d MMM, h:mm a').format(local);
  return '$relative · $absolute';
}

String txTypeKey(String? type) {
  switch (type) {
    case 'add':
      return 'txAdd';
    case 'withdraw':
      return 'txWithdraw';
    case 'adjust':
      return 'txAdjust';
    default:
      return type ?? '—';
  }
}

/// Trim excess decimals: `-4.000` → `-4.0`, `3.100` → `3.1`.
String formatQtyNumber(num qty) {
  if (qty == qty.roundToDouble()) return qty.toStringAsFixed(1);
  var s = qty.toStringAsFixed(3);
  while (s.contains('.') && s.endsWith('0')) {
    s = s.substring(0, s.length - 1);
  }
  return s;
}

String _unitLabel(num qty, String unit) {
  final abs = qty.abs();
  if (abs == 1) {
    switch (unit) {
      case 'bottles':
        return 'bottle';
      case 'boxes':
        return 'box';
      case 'pcs':
        return 'pc';
    }
  }
  return unit;
}

/// English inventory units — singular when |qty| is 1. Keeps sign.
String formatQtyUnit(num qty, String unit) {
  final qStr = formatQtyNumber(qty);
  if (unit.isEmpty) return qStr;
  return '$qStr ${_unitLabel(qty, unit)}';
}
