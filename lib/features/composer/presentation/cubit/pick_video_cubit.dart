import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';

part 'pick_video_state.dart';

/// D1: the device gallery, with the first video preselected.
class PickVideoCubit extends Cubit<PickVideoState> {
  new({required this._media}) : super(const PickVideoState());

  final MediaRepository _media;

  void started() => unawaited(_load());

  Future<void> _load() async {
    emit(state.copyWith(status: ViewStatus.loading, failure: () => null));
    try {
      final gallery = await _media.gallery();
      emit(
        state.copyWith(
          status: gallery.isEmpty ? ViewStatus.empty : ViewStatus.ready,
          gallery: gallery,
          selectedId: () => gallery.firstOrNull?.id,
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

  void itemTapped(String id) => emit(state.copyWith(selectedId: () => id));

  void tabChanged(PickVideoTab tab) => emit(state.copyWith(tab: tab));
}
