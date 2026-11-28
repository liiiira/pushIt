part of 'drafts_cubit.dart';

final class DraftsState extends Equatable {
  const new({
    this.status = ViewStatus.initial,
    this.drafts = const [],
    this.failure,
  });

  final ViewStatus status;
  final List<Post> drafts;
  final AppFailure? failure;

  DraftsState copyWith({
    ViewStatus? status,
    List<Post>? drafts,
    AppFailure? Function()? failure,
  }) => DraftsState(
    status: status ?? this.status,
    drafts: drafts != null ? List.unmodifiable(drafts) : this.drafts,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, drafts, failure];
}
