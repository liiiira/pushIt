import 'package:flutter_test/flutter_test.dart';

import 'conventions.dart';

List<String> _rulesBroken(String path, String content) =>
    checkSource(SourceFile(path, content)).map((v) => v.rule).toList();

void main() {
  group('the codebase', () {
    test('follows docs/CONVENTIONS.md §8', () {
      final violations = scanLib();

      expect(
        violations,
        isEmpty,
        reason: 'Fix these:\n${violations.join('\n')}',
      );
    });
  });

  group('rule 1: no Flutter in lib/domain', () {
    test('flags Flutter, Material and dart:ui imports', () {
      for (final import in [
        "import 'package:flutter/foundation.dart';",
        "import 'package:flutter_bloc/flutter_bloc.dart';",
        "import 'package:material_ui/material_ui.dart';",
        "import 'dart:ui';",
      ]) {
        expect(_rulesBroken('lib/domain/entities/post.dart', import), [
          Rules.flutterInDomain,
        ], reason: import);
      }
    });

    test('allows pure Dart imports, and Flutter outside the domain', () {
      expect(
        _rulesBroken(
          'lib/domain/entities/post.dart',
          "import 'package:equatable/equatable.dart';",
        ),
        isEmpty,
      );
      expect(
        _rulesBroken(
          'lib/features/home/home.dart',
          "import 'package:flutter/widgets.dart';",
        ),
        isEmpty,
      );
    });
  });

  group('rule 2: colours only in the tokens', () {
    test('flags raw colours', () {
      for (final code in [
        'const c = Color(0xFF141414);',
        'final c = Colors.black;',
        'final c = Color.fromARGB(255, 0, 0, 0);',
      ]) {
        expect(_rulesBroken('lib/features/home/x.dart', code), [
          Rules.rawColour,
        ], reason: code);
      }
    });

    test('allows tokens, and raw colours in the tokens folder', () {
      expect(
        _rulesBroken('lib/features/home/x.dart', 'final c = AppColors.of;'),
        isEmpty,
      );
      expect(
        _rulesBroken(
          'lib/core/design_system/tokens/app_colors.dart',
          'const c = Color(0xFF141414);',
        ),
        isEmpty,
      );
    });
  });

  group('rule 3: text styles only in the design system', () {
    test('flags TextStyle outside the design system', () {
      expect(
        _rulesBroken('lib/features/home/x.dart', 'const s = TextStyle();'),
        [Rules.rawTextStyle],
      );
    });

    test('allows TextStyle inside the design system', () {
      expect(
        _rulesBroken(
          'lib/core/design_system/theme/app_theme.dart',
          'const s = TextStyle();',
        ),
        isEmpty,
      );
    });
  });

  group('rule 4: no literal Text in features and shared widgets', () {
    test('flags literal strings, even on the next line', () {
      for (final code in [
        "const w = Text('Hello');",
        'const w = Text("Hello");',
        "const w = Text(\n  'Hello',\n);",
      ]) {
        expect(_rulesBroken('lib/features/home/x.dart', code), [
          Rules.literalText,
        ], reason: code);
        expect(_rulesBroken('lib/core/design_system/widgets/x.dart', code), [
          Rules.literalText,
        ], reason: code);
      }
    });

    test('allows l10n text and other widgets ending in Text', () {
      for (final code in [
        'final w = Text(context.l10n.homeTitle);',
        "const w = SelectableText('x');",
      ]) {
        expect(
          _rulesBroken('lib/features/home/x.dart', code),
          isEmpty,
          reason: code,
        );
      }
    });
  });

  group('rule 5: other features only through their barrel', () {
    test('flags deep imports into another feature', () {
      expect(
        _rulesBroken(
          'lib/features/composer/presentation/pages/x.dart',
          "import 'package:pushit/features/plans/presentation/x.dart';",
        ),
        [Rules.deepFeatureImport],
      );
      expect(
        _rulesBroken(
          'lib/app/router/app_router.dart',
          "import 'package:pushit/features/home/home_routes.dart';",
        ),
        [Rules.deepFeatureImport],
      );
    });

    test('allows barrels and imports inside the same feature', () {
      expect(
        _rulesBroken(
          'lib/features/composer/presentation/pages/x.dart',
          "import 'package:pushit/features/plans/plans.dart';",
        ),
        isEmpty,
      );
      expect(
        _rulesBroken(
          'lib/features/composer/composer.dart',
          "export 'package:pushit/features/composer/composer_routes.dart';",
        ),
        isEmpty,
      );
    });
  });

  test('comment lines are ignored', () {
    expect(
      _rulesBroken('lib/features/home/x.dart', "/// Never Text('x') here."),
      isEmpty,
    );
  });

  test('a violation names the file, line and rule', () {
    final violations = checkSource(
      const SourceFile('lib/features/home/x.dart', "\n\nconst w = Text('a');"),
    );

    expect(
      violations.single.toString(),
      contains('lib/features/home/x.dart:3'),
    );
    expect(violations.single.toString(), contains(Rules.literalText));
  });
}
