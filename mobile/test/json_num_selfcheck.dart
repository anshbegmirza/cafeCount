import '../lib/core/json_num.dart';
import '../lib/core/formatters.dart';

void main() {
  assert(asNum('4.000') == 4);
  assert(asNum(null) == null);
  assert(asDouble('12.5') == 12.5);
  assert(formatQtyNumber(-4) == '-4.0');
  assert(formatQtyUnit(-4, 'L') == '-4.0 L');
  // ignore: avoid_print
  print('json_num + formatQtyUnit self-check ok');
}
