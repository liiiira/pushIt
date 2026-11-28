import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';

part 'caption_variants_state.dart';

/// D11: suggested captions for each selected platform (Pro).
class CaptionVariantsCubit extends Cubit<CaptionVariantsState> {
  new({
    required this._suggestions,
    required this._caption,
    required this._platforms,
  }) : super(const CaptionVariantsState());

  final CaptionSuggestionsRepository _suggestions;
  final String _caption;
  final Set<PlatformId> _platforms;

  void started() => unawaited(_load());

  Future<void> _load() async {
    emit(state.copyWith(status: ViewStatus.loading, failure: () => null));
    try {
      final suggestions = await _suggestions.suggest(_caption, _platforms);
      emit(
        state.copyWith(
          status: suggestions.isEmpty ? ViewStatus.empty : ViewStatus.ready,
          suggestions: suggestions,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: ViewStatus.failure,
          failure: () => error is AppFailure ? error : UnknownFailure(error),
        ),
      );
    }
  }

  /// [platform]'s suggestion was used.
  void used(PlatformId platform) =>
      emit(state.copyWith(used: {...state.used, platform}));
}
