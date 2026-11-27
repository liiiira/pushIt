import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/library_filter.dart';
import 'package:pushit/features/library/presentation/cubit/library_cubit.dart';

class _MockPostsRepository extends Mock implements PostsRepository;

Post _post(String id, TargetStatus status, {bool isDraft = false}) => Post(
  id: id,
  video: const VideoAsset(
    id: 'v',
    fileName: 'v.mp4',
    duration: Duration(seconds: 10),
    sizeBytes: 1,
    width: 1080,
    height: 1920,
  ),
  caption: id,
  targets: [PostTarget(platform: PlatformId.youtube, status: status)],
  isDraft: isDraft,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late _MockPostsRepository repository; // fresh for each test
  late StreamController<List<Post>> posts; // fresh for each test

  final scheduled = _post('s', TargetStatus.scheduled);
  final published = _post('p', TargetStatus.published);
  final draft = _post('d', TargetStatus.scheduled, isDraft: true);

  setUp(() {
    repository = _MockPostsRepository();
    posts = StreamController<List<Post>>();
    when(() => repository.watchPosts()).thenAnswer((_) => posts.stream);
  });

  // close() only completes once a listener got the done event.
  tearDown(() => unawaited(posts.close()));

  test('starts in the initial state', () {
    expect(LibraryCubit(posts: repository).state, const LibraryState());
  });

  blocTest<LibraryCubit, LibraryState>(
    'started loads the posts without drafts',
    build: () => LibraryCubit(posts: repository),
    act: (cubit) async {
      cubit.started();
      posts.add([scheduled, draft, published]);
    },
    expect: () => [
      const LibraryState(status: ViewStatus.loading),
      LibraryState(status: ViewStatus.ready, posts: [scheduled, published]),
    ],
  );

  blocTest<LibraryCubit, LibraryState>(
    'only drafts, or nothing, is empty',
    build: () => LibraryCubit(posts: repository),
    act: (cubit) async {
      cubit.started();
      posts.add([draft]);
    },
    expect: () => [
      const LibraryState(status: ViewStatus.loading),
      const LibraryState(status: ViewStatus.empty),
    ],
  );

  blocTest<LibraryCubit, LibraryState>(
    'follows every change of the posts',
    build: () => LibraryCubit(posts: repository),
    act: (cubit) async {
      cubit.started();
      posts.add([scheduled]);
      await Future<void>.delayed(Duration.zero);
      posts.add([scheduled, published]);
    },
    skip: 1,
    expect: () => [
      LibraryState(status: ViewStatus.ready, posts: [scheduled]),
      LibraryState(status: ViewStatus.ready, posts: [scheduled, published]),
    ],
  );

  blocTest<LibraryCubit, LibraryState>(
    'a failure is shown, and retry loads again',
    build: () => LibraryCubit(posts: repository),
    act: (cubit) async {
      cubit.started();
      posts.addError(const NetworkFailure());
      await Future<void>.delayed(Duration.zero);
      when(() => repository.watchPosts())
          .thenAnswer((_) => Stream.value([published]));
      cubit.retryTapped();
    },
    expect: () => [
      const LibraryState(status: ViewStatus.loading),
      const LibraryState(status: ViewStatus.failure, failure: NetworkFailure()),
      const LibraryState(status: ViewStatus.loading),
      LibraryState(status: ViewStatus.ready, posts: [published]),
    ],
  );

  blocTest<LibraryCubit, LibraryState>(
    'an unexpected error becomes an unknown failure',
    build: () => LibraryCubit(posts: repository),
    act: (cubit) async {
      cubit.started();
      posts.addError(StateError('boom'));
    },
    skip: 1,
    verify: (cubit) {
      expect(cubit.state.status, ViewStatus.failure);
      expect(cubit.state.failure, isA<UnknownFailure>());
    },
  );

  blocTest<LibraryCubit, LibraryState>(
    'filterChanged narrows the visible posts',
    build: () => LibraryCubit(posts: repository),
    seed: () =>
        LibraryState(status: ViewStatus.ready, posts: [scheduled, published]),
    act: (cubit) => cubit.filterChanged(LibraryFilter.published),
    expect: () => [
      LibraryState(
        status: ViewStatus.ready,
        posts: [scheduled, published],
        filter: LibraryFilter.published,
      ),
    ],
    verify: (cubit) => expect(cubit.state.visiblePosts, [published]),
  );
}
