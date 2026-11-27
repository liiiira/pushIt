import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/data/fake/fixtures/fixture_captions.dart';
import 'package:pushit/domain/domain.dart';

/// Canned variants, one per platform in [PlatformId] order. Pro and Studio
/// only: other plans get `LimitReachedFailure`.
final class FakeCaptionSuggestionsRepository
    implements CaptionSuggestionsRepository {
  const new(this._database);

  final FakeDatabase _database;

  @override
  Future<List<CaptionSuggestion>> suggest(
    String caption,
    Set<PlatformId> platforms,
  ) => _database.load(() {
    if (!_database.subscription.value.plan.hasCaptionVariants) {
      throw const LimitReachedFailure();
    }
    return List.unmodifiable([
      for (final platform in PlatformId.values)
        if (platforms.contains(platform))
          CaptionSuggestion(
            platform: platform,
            text: fixtureCaptionVariant(platform, caption),
          ),
    ]);
  });
}
