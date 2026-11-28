import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/caption_variants_cubit.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';
import 'package:pushit/features/composer/presentation/views/captions_view.dart';
import 'package:pushit/features/composer/presentation/widgets/caption_variants_sheet.dart';

import '../../../../helpers/helpers.dart';

class _MockComposer extends MockCubit<ComposerState> implements ComposerCubit;

class _MockVariants extends MockCubit<CaptionVariantsState>
    implements CaptionVariantsCubit;

const _state = ComposerState(
  draft: PostDraft(
    caption: 'Second half of the studio tour.',
    platforms: {PlatformId.youtube, PlatformId.tiktok},
    copies: [
      PlatformCopy(
        platform: PlatformId.youtube,
        title: 'Studio tour, part 2',
        text: 'Second half of the studio tour. #studiotour',
      ),
    ],
  ),
);

void main() {
  late _MockComposer composer; // fresh for each test

  setUpAll(() => registerFallbackValue(PlatformId.youtube));

  setUp(() {
    composer = _MockComposer();
    when(() => composer.state).thenReturn(_state);
  });

  Future<void> pump(WidgetTester tester, Widget child, {TestLayout? layout}) =>
      tester.pumpApp(
        BlocProvider<ComposerCubit>.value(value: composer, child: child),
        layout: layout,
      );

  group('D5 text per platform', () {
    testAcrossLayouts('YouTube: title and description', (tester, layout) async {
      await pump(tester, const CaptionsView(), layout: layout);
      expect(find.text('Text per platform'), findsOneWidget);
      expect(find.text('YouTube title'), findsOneWidget);
      expect(find.text('Studio tour, part 2'), findsOneWidget);
      expect(find.text('YouTube description'), findsOneWidget);
      expect(find.text('Changed from the main caption'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.text('Suggest variants'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('another platform: its caption, the main one by default', (
      tester,
    ) async {
      await pump(tester, const CaptionsView());
      await tester.tap(find.byTooltip('TikTok'));
      await tester.pump();
      expect(find.text('TikTok caption'), findsOneWidget);
      expect(find.text('Second half of the studio tour.'), findsOneWidget);
      expect(find.text('Reset'), findsNothing);

      await tester.enterText(find.byType(EditableText), 'POV');
      verify(() => composer.copyChanged(PlatformId.tiktok, text: 'POV'))
          .called(1);
    });

    testWidgets('editing the title and resetting', (tester) async {
      await pump(tester, const CaptionsView());
      await tester.enterText(find.byType(EditableText).first, 'New title');
      verify(() => composer.copyChanged(PlatformId.youtube, title: 'New title'))
          .called(1);
      await tester.tap(find.text('Reset'));
      verify(() => composer.copyReset(PlatformId.youtube)).called(1);
    });
  });

  group('D11 caption variants', () {
    late _MockVariants variants; // fresh for each test

    setUp(() => variants = _MockVariants());

    Future<void> pumpSheet(
      WidgetTester tester,
      CaptionVariantsState state, {
      TestLayout? layout,
    }) {
      when(() => variants.state).thenReturn(state);
      return pump(
        tester,
        Scaffold(
          body: BlocProvider<CaptionVariantsCubit>.value(
            value: variants,
            child: const CaptionVariantsSheet(),
          ),
        ),
        layout: layout,
      );
    }

    testAcrossLayouts('one suggestion per platform', (tester, layout) async {
      await pumpSheet(
        tester,
        const CaptionVariantsState(
          status: ViewStatus.ready,
          suggestions: [
            CaptionSuggestion(platform: PlatformId.youtube, text: 'A #shorts'),
            CaptionSuggestion(platform: PlatformId.tiktok, text: 'POV: a'),
          ],
        ),
        layout: layout,
      );
      expect(
        find.text(
          'Optional, on the Pro plan. Edit any of them before using it.',
        ),
        findsOneWidget,
      );
      expect(find.text('A #shorts'), findsOneWidget);
      expect(find.text('Use'), findsNWidgets(2));
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('Use takes the suggestion', (tester) async {
      await pumpSheet(
        tester,
        const CaptionVariantsState(
          status: ViewStatus.ready,
          suggestions: [
            CaptionSuggestion(platform: PlatformId.tiktok, text: 'POV: a'),
          ],
        ),
      );
      await tester.tap(find.text('Use'));
      verify(
        () => composer.suggestionUsed(
          const CaptionSuggestion(platform: PlatformId.tiktok, text: 'POV: a'),
        ),
      ).called(1);
      verify(() => variants.used(PlatformId.tiktok)).called(1);
    });

    testAcrossLayouts('on a plan without variants', (tester, layout) async {
      await pumpSheet(
        tester,
        const CaptionVariantsState(
          status: ViewStatus.failure,
          failure: LimitReachedFailure(),
        ),
        layout: layout,
      );
      expect(
        find.text('Caption variants are on the Pro plan.'),
        findsOneWidget,
      );
      expect(find.text('See plans'), findsOneWidget);
    });
  });
}
