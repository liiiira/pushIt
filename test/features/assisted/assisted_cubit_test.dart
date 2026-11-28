import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/assisted/presentation/cubit/assisted_cubit.dart';

class _MockPosts extends Mock implements PostsRepository;

final Post _post = Post(
  id: 'p1',
  video: const VideoAsset(
    id: 'v',
    fileName: 'v.mp4',
    duration: Duration(seconds: 52),
    sizeBytes: 1,
    width: 1080,
    height: 1920,
  ),
  caption: 'Behind the desk',
  targets: const [
    PostTarget(platform: PlatformId.instagram, status: TargetStatus.scheduled),
  ],
  isDraft: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late _MockPosts posts; // fresh for each test

  setUp(() {
    posts = _MockPosts();
    when(() => posts.watchPost('p1')).thenAnswer((_) => Stream.value(_post));
  });

  AssistedCubit build({PlatformId? platform = PlatformId.instagram}) =>
      AssistedCubit(
        postId: 'p1',
        platform: platform,
        mode: AssistedMode.post,
        posts: posts,
      );

  final ready = AssistedState(status: ViewStatus.ready, post: _post);

  blocTest<AssistedCubit, AssistedState>(
    'started loads the post',
    build: build,
    act: (cubit) => cubit.started(),
    expect: () => [const AssistedState(status: ViewStatus.loading), ready],
  );

  blocTest<AssistedCubit, AssistedState>(
    'an unknown platform cannot be helped with',
    build: () => build(platform: null),
    act: (cubit) => cubit.started(),
    expect: () => [
      const AssistedState(
        status: ViewStatus.failure,
        failure: NotFoundFailure(),
      ),
    ],
  );

  blocTest<AssistedCubit, AssistedState>(
    'openTapped ticks the first two steps',
    build: build,
    seed: () => ready,
    act: (cubit) => cubit.openTapped(),
    expect: () => [
      ready.copyWith(ticked: {0, 1}),
    ],
  );

  blocTest<AssistedCubit, AssistedState>(
    'stepToggled ticks and unticks a step',
    build: build,
    seed: () => ready,
    act: (cubit) => cubit
      ..stepToggled(2)
      ..stepToggled(2),
    expect: () => [
      ready.copyWith(ticked: {2}),
      ready,
    ],
  );

  blocTest<AssistedCubit, AssistedState>(
    'confirmTapped tells pushIt it is done',
    setUp: () =>
        when(() => posts.confirmAssisted('p1', PlatformId.instagram))
            .thenAnswer((_) async {}),
    build: build,
    seed: () => ready,
    act: (cubit) => cubit.confirmTapped(),
    expect: () => [ready.copyWith(outcome: AssistedOutcome.done)],
  );

  blocTest<AssistedCubit, AssistedState>(
    'remindTapped snoozes for 30 minutes',
    setUp: () => when(
      () => posts.snoozeAssisted(
        'p1',
        PlatformId.instagram,
        const Duration(minutes: 30),
      ),
    ).thenAnswer((_) async {}),
    build: build,
    seed: () => ready,
    act: (cubit) => cubit.remindTapped(),
    expect: () => [ready.copyWith(outcome: AssistedOutcome.snoozed)],
  );

  blocTest<AssistedCubit, AssistedState>(
    'a failed confirm is reported',
    setUp: () =>
        when(() => posts.confirmAssisted('p1', PlatformId.instagram))
            .thenThrow(const ValidationFailure()),
    build: build,
    seed: () => ready,
    act: (cubit) => cubit.confirmTapped(),
    expect: () => [
      ready.copyWith(actionFailure: () => const ValidationFailure()),
    ],
  );
}
