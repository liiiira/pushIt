import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/drafts_cubit.dart';
import 'package:pushit/features/composer/presentation/cubit/pick_video_cubit.dart';

class _MockMedia extends Mock implements MediaRepository;

class _MockPosts extends Mock implements PostsRepository;

const _items = [
  GalleryItem(
    id: 'g1',
    fileName: 'a.mp4',
    duration: Duration(seconds: 10),
    sizeBytes: 1,
    width: 1080,
    height: 1920,
  ),
  GalleryItem(
    id: 'g2',
    fileName: 'b.mp4',
    duration: Duration(seconds: 20),
    sizeBytes: 1,
    width: 1080,
    height: 1920,
  ),
];

Post _post(String id, {required bool isDraft}) => Post(
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
  isDraft: isDraft,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late _MockMedia media; // fresh for each test
  late _MockPosts posts; // fresh for each test

  setUp(() {
    media = _MockMedia();
    posts = _MockPosts();
  });

  group('PickVideoCubit', () {
    blocTest<PickVideoCubit, PickVideoState>(
      'loads the gallery and selects the first video',
      setUp: () => when(() => media.gallery()).thenAnswer((_) async => _items),
      build: () => PickVideoCubit(media: media),
      act: (cubit) => cubit.started(),
      expect: () => [
        const PickVideoState(status: ViewStatus.loading),
        const PickVideoState(
          status: ViewStatus.ready,
          gallery: _items,
          selectedId: 'g1',
        ),
      ],
    );

    blocTest<PickVideoCubit, PickVideoState>(
      'an empty gallery is empty; a failure is a failure',
      setUp: () =>
          when(() => media.gallery()).thenThrow(const NetworkFailure()),
      build: () => PickVideoCubit(media: media),
      act: (cubit) => cubit.started(),
      skip: 1,
      expect: () => [
        const PickVideoState(
          status: ViewStatus.failure,
          failure: NetworkFailure(),
        ),
      ],
    );

    blocTest<PickVideoCubit, PickVideoState>(
      'itemTapped selects; tabChanged switches tabs',
      build: () => PickVideoCubit(media: media),
      seed: () => const PickVideoState(
        status: ViewStatus.ready,
        gallery: _items,
        selectedId: 'g1',
      ),
      act: (cubit) => cubit
        ..itemTapped('g2')
        ..tabChanged(PickVideoTab.drafts),
      expect: () => [
        const PickVideoState(
          status: ViewStatus.ready,
          gallery: _items,
          selectedId: 'g2',
        ),
        const PickVideoState(
          status: ViewStatus.ready,
          gallery: _items,
          selectedId: 'g2',
          tab: PickVideoTab.drafts,
        ),
      ],
      verify: (cubit) => expect(cubit.state.selected, _items[1]),
    );
  });

  group('DraftsCubit', () {
    late StreamController<List<Post>> all; // fresh for each test

    setUp(() {
      all = StreamController();
      when(() => posts.watchPosts()).thenAnswer((_) => all.stream);
    });

    // close() only completes once a listener got the done event.
    tearDown(() => unawaited(all.close()));

    final draft = _post('d1', isDraft: true);
    final scheduled = _post('p1', isDraft: false);

    blocTest<DraftsCubit, DraftsState>(
      'lists drafts only',
      build: () => DraftsCubit(posts: posts),
      act: (cubit) async {
        cubit.started();
        all.add([scheduled, draft]);
      },
      expect: () => [
        const DraftsState(status: ViewStatus.loading),
        DraftsState(status: ViewStatus.ready, drafts: [draft]),
      ],
    );

    blocTest<DraftsCubit, DraftsState>(
      'no drafts is empty',
      build: () => DraftsCubit(posts: posts),
      act: (cubit) async {
        cubit.started();
        all.add([scheduled]);
      },
      skip: 1,
      expect: () => [const DraftsState(status: ViewStatus.empty)],
    );

    blocTest<DraftsCubit, DraftsState>(
      'discardTapped discards the draft',
      setUp: () =>
          when(() => posts.discardDraft('d1')).thenAnswer((_) async {}),
      build: () => DraftsCubit(posts: posts),
      act: (cubit) => cubit.discardTapped('d1'),
      verify: (_) => verify(() => posts.discardDraft('d1')).called(1),
    );
  });
}
