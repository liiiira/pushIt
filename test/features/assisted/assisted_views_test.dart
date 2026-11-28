import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/data/fake/fixtures/fixture_posts.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/assisted/presentation/cubit/assisted_cubit.dart';
import 'package:pushit/features/assisted/presentation/views/assisted_view.dart';

import '../../helpers/helpers.dart';

class _MockAssisted extends MockCubit<AssistedState> implements AssistedCubit;

Post _fixture(String id) => fixturePosts(testNow).firstWhere((p) => p.id == id);

void main() {
  late _MockAssisted cubit; // fresh for each test

  setUp(() {
    cubit = _MockAssisted();
    when(() => cubit.confirmTapped()).thenAnswer((_) async {});
    when(() => cubit.remindTapped()).thenAnswer((_) async {});
  });

  Future<void> pump(
    WidgetTester tester,
    AssistedState state, {
    required PlatformId platform,
    required AssistedMode mode,
    TestLayout? layout,
  }) {
    when(() => cubit.state).thenReturn(state);
    return tester.pumpApp(
      BlocProvider<AssistedCubit>.value(
        value: cubit,
        child: AssistedView(platform: platform, mode: mode),
      ),
      layout: layout,
    );
  }

  testAcrossLayouts('G2: steps to post on Instagram', (tester, layout) async {
    await pump(
      tester,
      AssistedState(
        status: ViewStatus.ready,
        post: _fixture(FixtureIds.behindTheDesk),
        ticked: const {0},
      ),
      platform: PlatformId.instagram,
      mode: AssistedMode.post,
      layout: layout,
    );
    expect(find.text('Assisted posting'), findsOneWidget);
    expect(find.text('Post Behind the desk on Instagram'), findsOneWidget);
    expect(find.text('Caption copied to the clipboard'), findsOneWidget);
    expect(find.text('Instagram opens with the video loaded'), findsOneWidget);
    expect(find.text('Paste the caption and post'), findsOneWidget);
    expect(find.text('Open Instagram'), findsOneWidget);
    expect(find.text('I posted it'), findsOneWidget);
    expect(find.text('Remind me in 30 min'), findsOneWidget);
  });

  testAcrossLayouts('G3: steps to delete on TikTok', (tester, layout) async {
    await pump(
      tester,
      AssistedState(
        status: ViewStatus.ready,
        post: _fixture(FixtureIds.morningBroll),
      ),
      platform: PlatformId.tiktok,
      mode: AssistedMode.delete,
      layout: layout,
    );
    expect(find.text('Delete on TikTok'), findsOneWidget);
    expect(find.text('Remove Morning b-roll from TikTok'), findsOneWidget);
    expect(
      find.text(
        'TikTok does not let apps delete videos. Open it, delete the video '
        'there, then confirm here.',
      ),
      findsOneWidget,
    );
    expect(find.text('TikTok opens on this video'), findsOneWidget);
    expect(find.text('Delete it from the video menu'), findsOneWidget);
    expect(find.text('I deleted it'), findsOneWidget);
    expect(find.text('Keep it on TikTok'), findsOneWidget);
  });

  testWidgets('I posted it and Remind me go to the cubit', (tester) async {
    await pump(
      tester,
      AssistedState(
        status: ViewStatus.ready,
        post: _fixture(FixtureIds.behindTheDesk),
      ),
      platform: PlatformId.instagram,
      mode: AssistedMode.post,
    );
    await tester.tap(find.text('I posted it'));
    verify(() => cubit.confirmTapped()).called(1);
    await tester.tap(find.text('Remind me in 30 min'));
    verify(() => cubit.remindTapped()).called(1);
  });
}
