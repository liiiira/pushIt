import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// One screen size, theme brightness and text scale to test under.
final class TestLayout {
  const new({
    required this.size,
    required this.brightness,
    required this.textScale,
  });

  /// Logical size, in dp.
  final Size size;
  final Brightness brightness;
  final double textScale;

  @override
  String toString() =>
      '${size.width.toInt()}x${size.height.toInt()} '
      '${brightness.name} x$textScale';
}

const _sizes = [Size(360, 800), Size(412, 915)];
const List<Brightness> _brightnesses = [Brightness.light, Brightness.dark];
const _textScales = [1.0, 1.3];

/// Every layout `testAcrossLayouts` runs: 2 sizes × 2 themes × 2 scales.
final List<TestLayout> testLayouts = List.unmodifiable([
  for (final size in _sizes)
    for (final brightness in _brightnesses)
      for (final textScale in _textScales)
        TestLayout(size: size, brightness: brightness, textScale: textScale),
]);

/// Runs [body] once per entry of [testLayouts].
///
/// The view is sized to the layout before [body] runs; pass the layout on
/// with `tester.pumpApp(widget, layout: layout)`. After [body], the test
/// fails on any pending exception (overflows included) and checks
/// `androidTapTargetGuideline` and `textContrastGuideline`.
void testAcrossLayouts(
  String description,
  Future<void> Function(WidgetTester tester, TestLayout layout) body, {
  bool? skip,
}) {
  final variant = ValueVariant<TestLayout>(testLayouts.toSet());
  testWidgets(
    description,
    (tester) async {
      final layout = variant.currentValue!;
      tester.view
        ..physicalSize = layout.size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final semantics = tester.ensureSemantics();
      try {
        await body(tester, layout);
        expect(
          tester.takeException(),
          isNull,
          reason: 'No overflow or build error under $layout',
        );
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      } finally {
        semantics.dispose();
      }
    },
    variant: variant,
    skip: skip,
  );
}
