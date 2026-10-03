import 'package:flutter_test/flutter_test.dart';
import 'package:visit_kuwait/l10n/strings.dart';

void main() {
  test('every English string has an Arabic version', () {
    final missing = strings['en']!.keys.where((k) => !strings['ar']!.containsKey(k)).toList();
    expect(missing, isEmpty, reason: 'Missing Arabic: $missing');
  });
}
