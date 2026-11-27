import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_caption_suggestions_repository.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

import 'fake_support.dart';

void main() {
  const caption = 'Second half of the studio tour.';
  const platforms = {
    PlatformId.tiktok,
    PlatformId.youtube,
    PlatformId.instagram,
  };

  for (final scenario in Scenario.values) {
    test('${scenario.name}: suggest', () async {
      final suggestions = FakeCaptionSuggestionsRepository(
        fakeDatabase(scenario),
      ).suggest(caption, platforms);

      switch (scenario) {
        case Scenario.error:
          await expectLater(suggestions, throwsA(isA<NetworkFailure>()));
        case Scenario.firstUse || Scenario.freeLimit:
          await expectLater(suggestions, throwsA(isA<LimitReachedFailure>()));
        case Scenario.populated || Scenario.offline || Scenario.slow:
          final result = await suggestions;
          expect(result.map((s) => s.platform), [
            PlatformId.youtube,
            PlatformId.instagram,
            PlatformId.tiktok,
          ]);
          for (final suggestion in result) {
            expect(suggestion.text, contains('studio tour'));
            expect(suggestion.text, isNot(caption));
          }
      }
    });
  }
}
