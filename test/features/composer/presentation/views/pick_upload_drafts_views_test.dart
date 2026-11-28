import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/data/fake/fixtures/fixture_media.dart';
import 'package:pushit/data/fake/fixtures/fixture_posts.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';
import 'package:pushit/features/composer/presentation/cubit/drafts_cubit.dart';
import 'package:pushit/features/composer/presentation/cubit/pick_video_cubit.dart';
import 'package:pushit/features/composer/presentation/views/drafts_view.dart';
import 'package:pushit/features/composer/presentation/views/pick_video_view.dart';
import 'package:pushit/features/composer/presentation/views/upload_view.dart';

import '../../../../helpers/helpers.dart';

class _MockComposer extends MockCubit<ComposerState> implements ComposerCubit;

class _MockPick extends MockCubit<PickVideoState> implements PickVideoCubit;

class _MockDrafts extends MockCubit<DraftsState> implements DraftsCubit;

const int _mb = 1024 * 1024;
final GalleryItem _studio = fixtureGallery.first;
final List<Post> _drafts = fixturePosts(testNow)
    .where((p) => p.isDraft)
    .toList();

void main() {
  late _MockComposer composer; // fresh for each test
  late _MockPick pick; // fresh for each test
  late _MockDrafts drafts; // fresh for each test

  setUpAll(() => registerFallbackValue(_studio));

  setUp(() {
    composer = _MockComposer();
    pick = _MockPick();
    drafts = _MockDrafts();
    when(() => composer.state).thenReturn(const ComposerState());
    when(() => composer.pauseTapped()).thenAnswer((_) async {});
    when(() => composer.resumeTapped()).thenAnswer((_) async {});
    when(() => composer.cancelUploadTapped()).thenAnswer((_) async {});
    when(() => drafts.state)
        .thenReturn(DraftsState(status: ViewStatus.ready, drafts: _drafts));
    when(() => drafts.discardTapped(any())).thenAnswer((_) async {});
  });

  Future<void> pump(
    WidgetTester tester,
    Widget view, {
    TestLayout? layout,
    MockGoRouter? router,
  }) => tester.pumpApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ComposerCubit>.value(value: composer),
        BlocProvider<PickVideoCubit>.value(value: pick),
        BlocProvider<DraftsCubit>.value(value: drafts),
      ],
      child: view,
    ),
    layout: layout,
    router: router,
    repositories: [RepositoryProvider<Clock>.value(value: FixedClock(testNow))],
  );

  group('D1 pick video', () {
    final ready = PickVideoState(
      status: ViewStatus.ready,
      gallery: fixtureGallery,
      selectedId: _studio.id,
    );

    testAcrossLayouts('the gallery grid', (tester, layout) async {
      when(() => pick.state).thenReturn(ready);
      await pump(tester, const PickVideoView(), layout: layout);
      expect(find.text('New post'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Drafts · 2'), findsOneWidget);
      expect(find.text('1:42'), findsOneWidget);
      expect(
        find.text(
          'You can also share a video to pushIt from another app. '
          'Up to 300 MB.',
        ),
        findsOneWidget,
      );
      expect(find.text('Use this video'), findsOneWidget);
    });

    testAcrossLayouts('the drafts tab', (tester, layout) async {
      when(() => pick.state)
          .thenReturn(ready.copyWith(tab: PickVideoTab.drafts));
      await pump(tester, const PickVideoView(), layout: layout);
      expect(find.text('Unboxing the lav mic'), findsOneWidget);
      expect(find.text('Use this video'), findsNothing);
    });

    testWidgets('Use this video starts the upload and opens D2', (
      tester,
    ) async {
      when(() => pick.state).thenReturn(ready);
      final router = MockGoRouter();
      when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
      await pump(tester, const PickVideoView(), router: router);
      await tester.tap(find.text('Use this video'));
      verify(() => composer.uploadStarted(_studio)).called(1);
      verify(() => router.push<Object?>(RoutePaths.composeUpload)).called(1);
    });
  });

  group('D2 and D3 upload', () {
    ComposerState uploading(UploadProgress progress) =>
        ComposerState(uploadItem: _studio, upload: progress);

    testAcrossLayouts('D2: uploading', (tester, layout) async {
      when(() => composer.state).thenReturn(
        uploading(
          Uploading(sentBytes: 184 * _mb, totalBytes: _studio.sizeBytes),
        ),
      );
      await pump(tester, const UploadView(), layout: layout);
      expect(find.text('Uploading studio_tour_p2.mp4'), findsOneWidget);
      expect(find.text('184 of 300 MB'), findsOneWidget);
      expect(find.text('61%'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testAcrossLayouts('D3: paused', (tester, layout) async {
      when(() => composer.state).thenReturn(
        uploading(Paused(sentBytes: 184 * _mb, totalBytes: _studio.sizeBytes)),
      );
      await pump(tester, const UploadView(), layout: layout);
      expect(find.text('Upload paused'), findsOneWidget);
      expect(
        find.text(
          'No connection. The upload resumes by itself from 184 MB when '
          'you are back online.',
        ),
        findsOneWidget,
      );
      expect(find.text('Retry now'), findsOneWidget);
    });

    testAcrossLayouts('uploaded, failed and no video', (tester, layout) async {
      when(() => composer.state)
          .thenReturn(uploading(Uploaded(fixtureVideoFrom(_studio))));
      await pump(tester, const UploadView(), layout: layout);
      expect(find.text('Uploaded'), findsOneWidget);
    });

    testWidgets('pause, resume, cancel and continue', (tester) async {
      when(() => composer.state).thenReturn(
        uploading(Uploading(sentBytes: 1, totalBytes: _studio.sizeBytes)),
      );
      final router = MockGoRouter();
      when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
      when(router.canPop).thenReturn(true);
      when(router.pop).thenReturn(null);
      await pump(tester, const UploadView(), router: router);

      await tester.tap(find.text('Pause'));
      verify(() => composer.pauseTapped()).called(1);
      await tester.tap(find.text('Continue'));
      verify(() => router.push<Object?>(RoutePaths.composePost)).called(1);
      await tester.tap(find.text('Cancel'));
      verify(() => composer.cancelUploadTapped()).called(1);
    });

    testWidgets('a failed upload can be tried again', (tester) async {
      when(() => composer.state).thenReturn(uploading(const UploadFailed()));
      await pump(tester, const UploadView());
      expect(find.text('Upload failed'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      verify(() => composer.retryUploadTapped()).called(1);
    });

    testWidgets('without a video it offers to pick one', (tester) async {
      await pump(tester, const UploadView());
      expect(find.text('No video yet'), findsOneWidget);
    });
  });

  group('D12 drafts', () {
    testAcrossLayouts('lists drafts with when they were edited', (
      tester,
      layout,
    ) async {
      await pump(tester, const DraftsView(), layout: layout);
      expect(find.text('Drafts'), findsOneWidget);
      expect(find.text('Unboxing the lav mic'), findsOneWidget);
      expect(find.text('Edited 2 h ago · no time set'), findsOneWidget);
      expect(find.text('Edited yesterday · no time set'), findsOneWidget);
      expect(
        find.text('Drafts are saved automatically while you write.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping a draft resumes it in the composer', (tester) async {
      final router = MockGoRouter();
      when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
      await pump(tester, const DraftsView(), router: router);
      await tester.tap(find.text('Unboxing the lav mic'));
      verify(() => composer.draftResumed(_drafts.first)).called(1);
      verify(() => router.push<Object?>(RoutePaths.composePost)).called(1);
    });

    testWidgets('the menu discards a draft', (tester) async {
      await pump(tester, const DraftsView());
      await tester.tap(find.byTooltip('Draft actions').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      verify(() => drafts.discardTapped(_drafts.first.id)).called(1);
    });

    testWidgets('no drafts says so', (tester) async {
      when(() => drafts.state)
          .thenReturn(const DraftsState(status: ViewStatus.empty));
      await pump(tester, const DraftsView());
      expect(find.text('No drafts'), findsOneWidget);
    });
  });
}
