import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/l10n/l10n.dart';

import 'helpers.dart';

final class _Repository {
  const new();
}

void main() {
  testWidgets('provides the app localizations', (tester) async {
    String? appName;

    await tester.pumpApp(
      Builder(
        builder: (context) {
          appName = context.l10n.commonAppName;
          return const SizedBox.shrink();
        },
      ),
    );

    expect(appName, 'pushIt');
  });

  testWidgets('provides the given repositories', (tester) async {
    const repository = _Repository();
    _Repository? found;

    await tester.pumpApp(
      Builder(
        builder: (context) {
          found = context.read<_Repository>();
          return const SizedBox.shrink();
        },
      ),
      repositories: [RepositoryProvider<_Repository>.value(value: repository)],
    );

    expect(found, same(repository));
  });

  testWidgets('hands navigation to the given router stub', (tester) async {
    final router = MockGoRouter();

    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => context.go('/somewhere'),
          child: const Text('go'),
        ),
      ),
      router: router,
    );
    await tester.tap(find.text('go'));

    verify(() => router.go('/somewhere')).called(1);
  });
}
