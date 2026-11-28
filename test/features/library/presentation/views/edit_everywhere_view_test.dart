import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/data/fake/fixtures/fixture_posts.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/edit_everywhere_cubit.dart';
import 'package:pushit/features/library/presentation/views/edit_everywhere_view.dart';

import '../../../../helpers/helpers.dart';

class _MockEditCubit extends MockCubit<EditEverywhereState>
    implements EditEverywhereCubit;

final Post _broll = fixturePosts(testNow)
    .firstWhere((p) => p.id == FixtureIds.morningBroll);

final EditEverywhereState _ready = EditEverywhereState(
  status: ViewStatus.ready,
  post: _broll,
  title: _broll.title,
  caption: _broll.caption,
);

void main() {
  late _MockEditCubit cubit; // fresh for each test

  setUp(() {
    cubit = _MockEditCubit();
    when(() => cubit.applyTapped()).thenAnswer((_) async {});
  });

  Future<void> pump(
    WidgetTester tester,
    EditEverywhereState state, {
    TestLayout? layout,
  }) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpApp(
      BlocProvider<EditEverywhereCubit>.value(
        value: cubit,
        child: const EditEverywhereView(),
      ),
      layout: layout,
    );
  }

  PrimaryButton applyButton(WidgetTester tester) =>
      tester.widget<PrimaryButton>(find.byType(PrimaryButton));

  testAcrossLayouts('F5: fields, where it applies, and the apply button', (
    tester,
    layout,
  ) async {
    await pump(tester, _ready, layout: layout);

    expect(find.text('Edit everywhere'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Caption'), findsOneWidget);
    expect(find.text('Morning b-roll'), findsOneWidget);
    expect(find.text('Where this applies'), findsOneWidget);
    expect(find.text('Title and description'), findsOneWidget);
    expect(find.text('Not editable by apps'), findsNWidgets(2));
    expect(find.text('Apply to 1 platform'), findsOneWidget);
    expect(applyButton(tester).onPressed, isNull, reason: 'nothing changed');
  });

  testWidgets('typing tells the cubit; a change enables apply', (tester) async {
    await pump(tester, _ready.copyWith(title: 'Morning light'));
    expect(applyButton(tester).onPressed, isNotNull);

    await tester.enterText(find.byType(EditableText).last, 'New caption');
    verify(() => cubit.captionChanged('New caption')).called(1);

    await tester.tap(find.text('Apply to 1 platform'));
    verify(() => cubit.applyTapped()).called(1);
  });

  testWidgets('when done, it goes back and says where it applied', (
    tester,
  ) async {
    final router = MockGoRouter();
    when(router.canPop).thenReturn(true);
    when(router.pop).thenReturn(null);
    whenListen(
      cubit,
      Stream.value(
        _ready.copyWith(
          results: () => const [
            EditResult(
              platform: PlatformId.youtube,
              outcome: EditOutcome.applied,
            ),
            EditResult(
              platform: PlatformId.tiktok,
              outcome: EditOutcome.notSupported,
            ),
          ],
        ),
      ),
      initialState: _ready,
    );
    await tester.pumpApp(
      BlocProvider<EditEverywhereCubit>.value(
        value: cubit,
        child: const EditEverywhereView(),
      ),
      router: router,
    );
    await tester.pump();
    expect(find.text('Updated on 1 platform'), findsOneWidget);
    verify(router.pop).called(1);
  });
}
