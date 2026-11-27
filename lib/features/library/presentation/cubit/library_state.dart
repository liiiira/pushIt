part of 'library_cubit.dart';

final class LibraryState extends Equatable {
  const new({
    this.status = ViewStatus.initial,
    this.posts = const [],
    this.filter = LibraryFilter.all,
    this.failure,
  });

  final ViewStatus status;

  /// Every non-draft post, newest first.
  final List<Post> posts;
  final LibraryFilter filter;
  final AppFailure? failure;

  /// The posts of the selected tab.
  List<Post> get visiblePosts => filterLibrary(posts, filter);

  LibraryState copyWith({
    ViewStatus? status,
    List<Post>? posts,
    LibraryFilter? filter,
    AppFailure? Function()? failure,
  }) => LibraryState(
    status: status ?? this.status,
    posts: posts != null ? List.unmodifiable(posts) : this.posts,
    filter: filter ?? this.filter,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, posts, filter, failure];
}
