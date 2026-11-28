import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pushit/core/preferences/app_preferences.dart';

part 'onboarding_state.dart';

/// A2–A4: the onboarding pager.
///
/// Finishing (Skip, or Next on the last page) only stores the onboarding as
/// done: the router then leaves the onboarding on its own (`appRedirect`).
class OnboardingCubit extends Cubit<OnboardingState> {
  new({required this._preferences}) : super(const OnboardingState());

  static const pageCount = 3;

  final AppPreferences _preferences;

  /// The user swiped to [page].
  void pageChanged(int page) => emit(state.copyWith(page: page));

  /// Next, or "Connect an account" on the last page.
  Future<void> nextTapped() async {
    if (state.isLastPage) {
      await _finish();
      return;
    }
    emit(state.copyWith(page: state.page + 1));
  }

  Future<void> skipTapped() => _finish();

  Future<void> _finish() => _preferences.setOnboarded();
}
