part of 'caption_variants_cubit.dart';

final class CaptionVariantsState extends Equatable {
  const new({
    this.status = ViewStatus.initial,
    this.suggestions = const [],
    this.used = const {},
    this.failure,
  });

  final ViewStatus status;
  final List<CaptionSuggestion> suggestions;

  /// Platforms whose suggestion was already used.
  final Set<PlatformId> used;
  final AppFailure? failure;

  CaptionVariantsState copyWith({
    ViewStatus? status,
    List<CaptionSuggestion>? suggestions,
    Set<PlatformId>? used,
    AppFailure? Function()? failure,
  }) => CaptionVariantsState(
    status: status ?? this.status,
    suggestions: suggestions != null
        ? List.unmodifiable(suggestions)
        : this.suggestions,
    used: used != null ? Set.unmodifiable(used) : this.used,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, suggestions, used, failure];
}
