import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/data/fake/fixtures/fixture_accounts.dart';
import 'package:pushit/data/fake/fixtures/fixture_media.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';
import 'package:pushit/features/composer/presentation/views/composer_view.dart';
import 'package:pushit/features/composer/presentation/views/cover_view.dart';
import 'package:pushit/features/composer/presentation/views/tiktok_settings_view.dart';

import '../../../../helpers/helpers.dart';

class _MockComposer extends MockCubit<ComposerState> implements ComposerCubit;

final VideoAsset _studio = fixtureVideo('gallery-studio-tour');

final ComposerState _studioTour = ComposerState(
  draft: PostDraft(
    video: _studio,
    caption: 'Second half of the studio tour.',
    platforms: const {
      PlatformId.youtube,
      PlatformId.instagram,
      PlatformId.tiktok,
    },
    copies: const [
      PlatformCopy(platform: PlatformId.youtube, title: 'T', text: 'x'),
    ],
    coverAt: const Duration(seconds: 4),
  ),
  upload: Uploaded(_studio),
  accounts: fixtureAccounts(testNow),
  plan: proPlan,
  hasPlatformChoice: true,
);

void main() {
  late _MockComposer composer; // fresh for each test

  setUpAll(() {
    registerFallbackValue(PlatformId.youtube);
    registerFallbackValue(const TikTokSettings());
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    composer = _MockComposer();
    when(() => composer.closeTapped()).thenAnswer((_) async => false);
  });

  Future<void> pump(
    WidgetTester tester,
    Widget view,
    ComposerState state, {
    TestLayout? layout,
    MockGoRouter? router,
  }) {
    when(() => composer.state).thenReturn(state);
    return tester.pumpApp(
      BlocProvider<ComposerCubit>.value(value: composer, child: view),
      layout: layout,
      router: router,
      repositories: [
        RepositoryProvider<Clock>.value(value: FixedClock(testNow)),
      ],
    );
  }

  group('D4 composer', () {
    testAcrossLayouts('caption, platforms, settings and Schedule', (
      tester,
      layout,
    ) async {
      await pump(tester, const ComposerView(), _studioTour, layout: layout);
      expect(find.text('New post'), findsOneWidget);
      expect(find.text('Drafts'), findsOneWidget);
      expect(find.text('Second half of the studio tour.'), findsOneWidget);
      expect(
        find.text('Facebook Reels: 90 s at most. This video is 1:42.'),
        findsOneWidget,
      );
      expect(find.text('Text per platform'), findsOneWidget);
      expect(find.text('1 change'), findsOneWidget);
      expect(find.text('Frame at 0:04'), findsOneWidget);
      expect(find.text('TikTok settings'), findsOneWidget);
      expect(find.text('Choose'), findsNWidgets(2));
      expect(find.text('When'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
    });

    testAcrossLayouts('without accounts it asks to connect one', (
      tester,
      layout,
    ) async {
      await pump(
        tester,
        const ComposerView(),
        ComposerState(draft: PostDraft(video: _studio)),
        layout: layout,
      );
      expect(find.text('Connect an account first'), findsOneWidget);
    });

    testWidgets('tapping a platform toggles it', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, const ComposerView(), _studioTour);
      final facebook = find.bySemanticsLabel('Facebook, not selected');
      await tester.ensureVisible(facebook);
      await tester.tap(facebook);
      verify(() => composer.platformToggled(PlatformId.facebook)).called(1);
      semantics.dispose();
    });

    testWidgets('typing updates the caption', (tester) async {
      await pump(tester, const ComposerView(), _studioTour);
      await tester.enterText(find.byType(EditableText), 'New');
      verify(() => composer.captionChanged('New')).called(1);
    });

    testWidgets('rows open their screens; Schedule opens the check', (
      tester,
    ) async {
      final router = MockGoRouter();
      when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
      await pump(tester, const ComposerView(), _studioTour, router: router);

      for (final (label, path) in [
        ('Text per platform', RoutePaths.composePostCaptions),
        ('Cover', RoutePaths.composePostCover),
        ('TikTok settings', RoutePaths.composePostTikTok),
        ('Drafts', RoutePaths.composeDrafts),
        ('Schedule', RoutePaths.composePostCheck),
      ]) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        verify(() => router.push<Object?>(path)).called(1);
      }
    });

    testWidgets('TikTok settings show only with TikTok selected', (
      tester,
    ) async {
      await pump(
        tester,
        const ComposerView(),
        _studioTour.copyWith(
          draft: _studioTour.draft.copyWith(platforms: {PlatformId.youtube}),
        ),
      );
      expect(find.text('TikTok settings'), findsNothing);
    });
  });

  group('D6 cover', () {
    testAcrossLayouts('frames to pick from', (tester, layout) async {
      await pump(tester, const CoverView(), _studioTour, layout: layout);
      expect(find.text('Cover'), findsOneWidget);
      expect(
        find.text(
          'Frame at 0:04. Used as the cover where the platform allows one.',
        ),
        findsOneWidget,
      );
      expect(find.text('Use this frame'), findsOneWidget);
    });

    testWidgets('picking a frame and using it', (tester) async {
      final semantics = tester.ensureSemantics();
      final router = MockGoRouter();
      when(router.canPop).thenReturn(true);
      when(router.pop).thenReturn(null);
      await pump(tester, const CoverView(), _studioTour, router: router);
      final frame = find.bySemanticsLabel('Frame at 0:17');
      await tester.ensureVisible(frame);
      await tester.tap(frame);
      await tester.pump();
      expect(find.textContaining('Frame at 0:17.'), findsOneWidget);
      await tester.tap(find.text('Use this frame'));
      verify(() => composer.coverChanged(const Duration(seconds: 17)))
          .called(1);
      verify(router.pop).called(1);
      semantics.dispose();
    });
  });

  group('D7 TikTok settings', () {
    testAcrossLayouts('privacy, permissions and disclosure', (
      tester,
      layout,
    ) async {
      await pump(
        tester,
        const TikTokSettingsView(),
        _studioTour,
        layout: layout,
      );
      expect(find.text('Who can see this video'), findsOneWidget);
      for (final label in [
        'Everyone',
        'Friends',
        'Only me',
        'Comments',
        'Duet',
        'Stitch',
        'Promotes a brand or product',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('choices go to the composer', (tester) async {
      await pump(tester, const TikTokSettingsView(), _studioTour);
      await tester.tap(find.text('Friends'));
      verify(
        () => composer.tiktokChanged(
          const TikTokSettings(privacy: TikTokPrivacy.friends),
        ),
      ).called(1);
      await tester.tap(find.text('Duet'));
      verify(
        () => composer.tiktokChanged(const TikTokSettings(allowDuet: true)),
      ).called(1);
    });
  });
}
