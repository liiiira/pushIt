import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/data/fake/scenario.dart';

void main() {
  test('fromName finds every scenario by name', () {
    for (final scenario in Scenario.values) {
      expect(Scenario.fromName(scenario.name), scenario);
    }
  });

  test('fromName falls back to populated', () {
    expect(Scenario.fromName('nope'), Scenario.populated);
    expect(Scenario.fromName(''), Scenario.populated);
  });
}
