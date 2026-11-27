import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/l10n/l10n.dart';

import 'test_across_layouts.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] as the home of an app with the pushIt theme and
  /// localizations.
  ///
  /// - [layout]: brightness and text scale (the size is set by
  ///   `testAcrossLayouts`). Defaults to light at scale 1.
  /// - [router]: a `MockGoRouter`, to verify `context.go` and friends.
  /// - [repositories]: what pages read with `context.read<XRepository>()`.
  Future<void> pumpApp(
    Widget widget, {
    TestLayout? layout,
    GoRouter? router,
    List<RepositoryProvider<Object?>> repositories = const [],
  }) {
    final brightness = layout?.brightness ?? Brightness.light;
    final textScale = layout?.textScale ?? 1;
    final app = MaterialApp(
      theme: brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light(),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child ?? const SizedBox.shrink(),
      ),
      home: router == null
          ? widget
          : InheritedGoRouter(goRouter: router, child: widget),
    );
    return pumpWidget(
      repositories.isEmpty
          ? app
          : MultiRepositoryProvider(providers: repositories, child: app),
    );
  }
}
