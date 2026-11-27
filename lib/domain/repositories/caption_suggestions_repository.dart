import 'package:pushit/domain/entities/caption_suggestion.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// Caption variants per platform (D11, Pro). Methods throw `AppFailure`.
abstract interface class CaptionSuggestionsRepository {
  Future<List<CaptionSuggestion>> suggest(
    String caption,
    Set<PlatformId> platforms,
  );
}
