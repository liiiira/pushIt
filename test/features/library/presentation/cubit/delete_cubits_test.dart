import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/delete_confirm_cubit.dart';
import 'package:pushit/features/library/presentation/cubit/delete_result_cubit.dart';

class _MockPosts extends Mock implements PostsRepository;

final Post _post = Post(
  id: 'p1',
  video: const VideoAsset(
    id: 'v',
    fileName: 'v.mp4',
    duration: Duration(seconds: 38),
    sizeBytes: 1,
    width: 1080,
    height: 1920,
  ),
  caption: 'Morning b-roll',
  targets: const [
    PostTarget(platform: PlatformId.youtube, status: TargetStatus.published),
  ],
  isDraft: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

const _pending = [
  DeletionStep(
    platform: PlatformId.youtube,
    method: DeleteMethod.automatic,
    outcome: DeletionOutcome.pending,
  ),
];

const _failed = [
  DeletionStep(
    platform: PlatformId.youtube,
    method: DeleteMethod.automatic,
    outcome: DeletionOutcome.failed,
  ),
];

const _removed = [
  DeletionStep(
    platform: PlatformId.youtube,
    method: DeleteMethod.automatic,
    outcome: DeletionOutcome.removed,
  ),
];

void main() {
  late _MockPosts posts; // fresh for each test

  setUp(() => posts = _MockPosts());

  group('DeleteConfirmCubit', () {
    blocTest<DeleteConfirmCubit, DeleteConfirmState>(
      'loads the post once',
      setUp: () =>
          when(() => posts.watchPost('p1'))
              .thenAnswer((_) => Stream.value(_post)),
      build: () => DeleteConfirmCubit(postId: 'p1', posts: posts),
      act: (cubit) => cubit.started(),
      expect: () => [
        const DeleteConfirmState(status: ViewStatus.loading),
        DeleteConfirmState(status: ViewStatus.ready, post: _post),
      ],
    );

    blocTest<DeleteConfirmCubit, DeleteConfirmState>(
      'a missing post is a failure',
      setUp: () =>
          when(() => posts.watchPost('p1'))
              .thenAnswer((_) => Stream.error(const NotFoundFailure())),
      build: () => DeleteConfirmCubit(postId: 'p1', posts: posts),
      act: (cubit) => cubit.started(),
      skip: 1,
      expect: () => [
        const DeleteConfirmState(
          status: ViewStatus.failure,
          failure: NotFoundFailure(),
        ),
      ],
    );
  });

  group('DeleteResultCubit', () {
    late StreamController<List<DeletionStep>> steps; // fresh for each test

    setUp(() {
      steps = StreamController();
      when(() => posts.deleteEverywhere('p1')).thenAnswer((_) => steps.stream);
    });

    // close() only completes once a listener got the done event.
    tearDown(() => unawaited(steps.close()));

    blocTest<DeleteResultCubit, DeleteResultState>(
      'follows the deletion step by step',
      build: () => DeleteResultCubit(postId: 'p1', posts: posts),
      act: (cubit) async {
        cubit.started();
        steps
          ..add(_pending)
          ..add(_removed);
      },
      expect: () => [
        const DeleteResultState(status: ViewStatus.loading),
        const DeleteResultState(status: ViewStatus.ready, steps: _pending),
        const DeleteResultState(status: ViewStatus.ready, steps: _removed),
      ],
    );

    blocTest<DeleteResultCubit, DeleteResultState>(
      'retryTapped starts the deletion again',
      build: () => DeleteResultCubit(postId: 'p1', posts: posts),
      seed: () =>
          const DeleteResultState(status: ViewStatus.ready, steps: _failed),
      act: (cubit) async {
        cubit.retryTapped();
        steps.add(_removed);
      },
      expect: () => [
        const DeleteResultState(status: ViewStatus.ready, steps: _removed),
      ],
      verify: (_) => verify(() => posts.deleteEverywhere('p1')).called(1),
    );

    blocTest<DeleteResultCubit, DeleteResultState>(
      'a stream error is a failure',
      build: () => DeleteResultCubit(postId: 'p1', posts: posts),
      act: (cubit) async {
        cubit.started();
        steps.addError(const NotFoundFailure());
      },
      skip: 1,
      expect: () => [
        const DeleteResultState(
          status: ViewStatus.failure,
          failure: NotFoundFailure(),
        ),
      ],
    );
  });
}
