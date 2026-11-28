part of 'onboarding_cubit.dart';

final class OnboardingState extends Equatable {
  const new({this.page = 0});

  /// Zero-based: A2, A3, A4.
  final int page;

  bool get isLastPage => page == OnboardingCubit.pageCount - 1;

  OnboardingState copyWith({int? page}) =>
      OnboardingState(page: page ?? this.page);

  @override
  List<Object?> get props => [page];
}
