import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/data/fake/fixtures/fixture_accounts.dart';
import 'package:pushit/data/fake/fixtures/fixture_media.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';
import 'package:pushit/features/composer/presentation/cubit/schedule_sheet_cubit.dart';
import 'package:pushit/features/composer/presentation/views/check_view.dart';
import 'package:pushit/features/composer/presentation/views/scheduled_view.dart';
import 'package:pushit/features/composer/presentation/widgets/schedule_sheet.dart';

import '../../../../helpers/helpers.dart';

class _MockComposer extends MockCubit<ComposerState> implements ComposerCubit;

final VideoAsset _video = fixtureVideo('gallery-studio-tour');
final DateTime _at = DateTime(2026, 11, 17, 19);

final ComposerState _checking = ComposerState(
  draft: PostDraft(
    video: _video,
    platforms: const {
      PlatformId.youtube,
      PlatformId.instagram,
      PlatformId.tiktok,
      PlatformId.facebook,
    },
  ),
  accounts: fixtureAccounts(testNow),
  plan: proPlan,
  hasPlatformChoice: true,
);

final Post _scheduled = Post(
  id: 'post-1',
  video: _video,
  caption: 'Studio tour',
  targets: [
    for (final platform in [
      PlatformId.youtube,
      PlatformId.instagram,
      PlatformId.tiktok,
    ])
      PostTarget(
        platform: platform,
        scheduledAt: _at,
        status: TargetStatus.scheduled,
      ),
  ],
  isDraft: false,
  createdAt: testNow,
  updatedAt: testNow,
);

void main() {
  late _MockComposer composer; // fresh for each test

  setUp(() => composer = _MockComposer());

  Future<void> pump(
    WidgetTester tester,
    Widget child,
    ComposerState state, {
    TestLayout? layout,
  }) {
    when(() => composer.state).thenReturn(state);
    return tester.pumpApp(
      BlocProvider<ComposerCubit>.value(value: composer, child: child),
      layout: layout,
      repositories: [
        RepositoryProvider<Clock>.value(value: FixedClock(testNow)),
      ],
    );
  }

  testAcrossLayouts('D8: one row per platform, with its fix', (
    tester,
    layout,
  ) async {
    await pump(tester, const CheckView(), _checking, layout: layout);
    expect(
      find.text("Your video against each platform's limits."),
      findsOneWidget,
    );
    expect(find.text('Ready'), findsNWidgets(2));
    expect(find.text('Too long: 1:42, limit is 1:30'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
    expect(find.text('Reconnect'), findsOneWidget);
    expect(find.text('3 problems to fix before scheduling.'), findsOneWidget);
    expect(find.text('Continue with 2 platforms'), findsOneWidget);
    expect(find.text('Back to post'), findsOneWidget);
  });

  testAcrossLayouts('D13: when, where, and the assisted reminder', (
    tester,
    layout,
  ) async {
    await pump(
      tester,
      const ScheduledView(),
      ComposerState(
        scheduledPost: _scheduled,
        accounts: fixtureAccounts(testNow),
      ),
      layout: layout,
    );
    expect(find.text('Scheduled'), findsOneWidget);
    expect(
      find.text(
        'Tue 17 Nov at 19:00 on YouTube. Instagram and TikTok are '
        'assisted, so we will remind you at 19:00.',
      ),
      findsOneWidget,
    );
    expect(find.text('View in calendar'), findsOneWidget);
    expect(find.text('New post'), findsOneWidget);
  });

  group('D9 and D10', () {
    Future<void> pumpSheet(
      WidgetTester tester, {
      ScheduleChoice? initial,
      TestLayout? layout,
    }) => tester.pumpApp(
      Scaffold(
        body: SingleChildScrollView(
          child: BlocProvider(
            create: (_) => ScheduleSheetCubit(
              platforms: const {PlatformId.youtube, PlatformId.tiktok},
              now: testNow,
              initial: initial,
            ),
            child: const ScheduleSheet(),
          ),
        ),
      ),
      layout: layout,
    );

    testAcrossLayouts('D9: one time', (tester, layout) async {
      await pumpSheet(tester, initial: SameTime(_at), layout: layout);
      expect(find.text('One time'), findsOneWidget);
      expect(find.text('18:45'), findsOneWidget);
      expect(find.text('19:00'), findsOneWidget);
      expect(find.text('19:15'), findsOneWidget);
      expect(find.text('Tue 17 Nov · your local time'), findsOneWidget);
      expect(find.text('Set time'), findsOneWidget);
    });

    testAcrossLayouts('D10: per platform', (tester, layout) async {
      await pumpSheet(
        tester,
        initial: PerPlatform({
          PlatformId.youtube: _at,
          PlatformId.tiktok: _at.add(const Duration(minutes: 90)),
        }),
        layout: layout,
      );
      expect(find.text('YouTube'), findsOneWidget);
      expect(find.text('20:30'), findsOneWidget);
      expect(find.text('Set times'), findsOneWidget);
    });

    testWidgets('a past time cannot be set', (tester) async {
      await pumpSheet(tester, initial: SameTime(testNow));
      expect(find.text('Pick a time later than now.'), findsOneWidget);
    });
  });
}
