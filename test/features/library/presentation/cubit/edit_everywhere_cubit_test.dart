import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/edit_everywhere_cubit.dart';

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
  caption: 'First light.',
  copies: const [
    PlatformCopy(
      platform: PlatformId.youtube,
      title: 'Morning b-roll',
      text: 'First light.',
    ),
  ],
  targets: const [
    PostTarget(platform: PlatformId.youtube, status: TargetStatus.published),
    PostTarget(platform: PlatformId.tiktok, status: TargetStatus.published),
  ],
  isDraft: false,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

const _results = [
  EditResult(platform: PlatformId.youtube, outcome: EditOutcome.applied),
  EditResult(platform: PlatformId.tiktok, outcome: EditOutcome.notSupported),
];

void main() {
  late _MockPosts posts; // fresh for each test

  setUp(() {
    posts = _MockPosts();
    when(() => posts.watchPost('p1')).thenAnswer((_) => Stream.value(_post));
  });

  EditEverywhereCubit build() =>
      EditEverywhereCubit(postId: 'p1', posts: posts);

  final ready = EditEverywhereState(
    status: ViewStatus.ready,
    post: _post,
    title: 'Morning b-roll',
    caption: 'First light.',
  );

  blocTest<EditEverywhereCubit, EditEverywhereState>(
    'started fills the fields from the post',
    build: build,
    act: (cubit) => cubit.started(),
    expect: () => [
      const EditEverywhereState(status: ViewStatus.loading),
      ready,
    ],
  );

  blocTest<EditEverywhereCubit, EditEverywhereState>(
    'a missing post is a failure',
    setUp: () =>
        when(() => posts.watchPost('p1'))
            .thenAnswer((_) => Stream.error(const NotFoundFailure())),
    build: build,
    act: (cubit) => cubit.started(),
    skip: 1,
    expect: () => [
      const EditEverywhereState(
        status: ViewStatus.failure,
        failure: NotFoundFailure(),
      ),
    ],
  );

  test('canApply needs a change and a caption', () {
    expect(ready.canApply, isFalse);
    expect(ready.copyWith(title: 'Morning light').canApply, isTrue);
    expect(ready.copyWith(caption: '  ').canApply, isFalse);
    expect(
      ready.copyWith(caption: 'New', isSubmitting: true).canApply,
      isFalse,
    );
  });

  blocTest<EditEverywhereCubit, EditEverywhereState>(
    'applyTapped sends only what changed, then reports the results',
    setUp: () => when(
      () => posts.editEverywhere(
        'p1',
        title: any(named: 'title'),
        caption: any(named: 'caption'),
      ),
    ).thenAnswer((_) async => _results),
    build: build,
    seed: () => ready,
    act: (cubit) async {
      cubit.captionChanged('New caption');
      await cubit.applyTapped();
    },
    expect: () => [
      ready.copyWith(caption: 'New caption'),
      ready.copyWith(caption: 'New caption', isSubmitting: true),
      ready.copyWith(caption: 'New caption', results: () => _results),
    ],
    verify: (_) =>
        verify(() => posts.editEverywhere('p1', caption: 'New caption'))
            .called(1),
  );

  blocTest<EditEverywhereCubit, EditEverywhereState>(
    'a failed apply is reported and the fields kept',
    setUp: () => when(
      () => posts.editEverywhere(
        'p1',
        title: any(named: 'title'),
        caption: any(named: 'caption'),
      ),
    ).thenThrow(const NetworkFailure()),
    build: build,
    seed: () => ready.copyWith(title: 'Morning light'),
    act: (cubit) => cubit.applyTapped(),
    expect: () => [
      ready.copyWith(title: 'Morning light', isSubmitting: true),
      ready.copyWith(
        title: 'Morning light',
        actionFailure: () => const NetworkFailure(),
      ),
    ],
  );

  blocTest<EditEverywhereCubit, EditEverywhereState>(
    'applyTapped does nothing when nothing changed',
    build: build,
    seed: () => ready,
    act: (cubit) => cubit.applyTapped(),
    expect: () => <EditEverywhereState>[],
  );
}
