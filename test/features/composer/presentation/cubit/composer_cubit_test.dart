import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';

class _MockMedia extends Mock implements MediaRepository;

class _MockPosts extends Mock implements PostsRepository;

class _MockAccounts extends Mock implements AccountsRepository;

class _MockSubscription extends Mock implements SubscriptionRepository;

const _item = GalleryItem(
  id: 'g1',
  fileName: 'studio_tour_p2.mp4',
  duration: Duration(minutes: 1, seconds: 42),
  sizeBytes: 300,
  width: 1080,
  height: 1920,
);

const _video = VideoAsset(
  id: 'video-g1',
  fileName: 'studio_tour_p2.mp4',
  duration: Duration(minutes: 1, seconds: 42),
  sizeBytes: 300,
  width: 1080,
  height: 1920,
);

void main() {
  late _MockMedia media; // fresh for each test
  late StreamController<UploadProgress> upload; // fresh for each test

  setUp(() {
    media = _MockMedia();
    upload = StreamController.broadcast();
    when(() => media.upload('g1')).thenAnswer((_) => upload.stream);
    when(() => media.pause()).thenAnswer((_) async {});
    when(() => media.resume()).thenAnswer((_) async {});
    when(() => media.cancel()).thenAnswer((_) async {});
  });

  // close() only completes once a listener got the done event.
  tearDown(() => unawaited(upload.close()));

  ComposerCubit build() => ComposerCubit(
    media: media,
    posts: _MockPosts(),
    accounts: _MockAccounts(),
    subscription: _MockSubscription(),
  );

  const started = ComposerState(
    uploadItem: _item,
    upload: Uploading(sentBytes: 0, totalBytes: 300),
  );

  blocTest<ComposerCubit, ComposerState>(
    'uploadStarted follows the upload and keeps the uploaded video',
    build: build,
    act: (cubit) async {
      cubit.uploadStarted(_item);
      upload
        ..add(const Uploading(sentBytes: 150, totalBytes: 300))
        ..add(const Uploaded(_video));
    },
    expect: () => [
      started,
      started.copyWith(
        upload: () => const Uploading(sentBytes: 150, totalBytes: 300),
      ),
      started.copyWith(
        upload: () => const Uploaded(_video),
        draft: const PostDraft(video: _video),
      ),
    ],
  );

  blocTest<ComposerCubit, ComposerState>(
    'pause and resume go to the media repository; the stream reports it',
    build: build,
    seed: () => started,
    act: (cubit) async {
      cubit.uploadStarted(_item);
      await cubit.pauseTapped();
      upload.add(const Paused(sentBytes: 184, totalBytes: 300));
      await cubit.resumeTapped();
    },

    expect: () => [
      started.copyWith(
        upload: () => const Paused(sentBytes: 184, totalBytes: 300),
      ),
    ],
    verify: (_) {
      verify(() => media.pause()).called(1);
      verify(() => media.resume()).called(1);
    },
  );

  blocTest<ComposerCubit, ComposerState>(
    'cancelUploadTapped stops the upload and forgets the video',
    build: build,
    seed: () => started,
    act: (cubit) => cubit.cancelUploadTapped(),
    expect: () => [const ComposerState()],
    verify: (_) => verify(() => media.cancel()).called(1),
  );

  blocTest<ComposerCubit, ComposerState>(
    'a failed upload can be started again',
    build: build,
    act: (cubit) async {
      cubit.uploadStarted(_item);
      upload.add(const UploadFailed());
      await Future<void>.delayed(Duration.zero);
      cubit.retryUploadTapped();
    },
    expect: () => [
      started,
      started.copyWith(upload: () => const UploadFailed()),
      started,
    ],
    verify: (_) => verify(() => media.upload('g1')).called(2),
  );

  blocTest<ComposerCubit, ComposerState>(
    'draftResumed loads a saved draft',
    build: build,
    act: (cubit) => cubit.draftResumed(
      Post(
        id: 'draft-1',
        video: _video,
        caption: 'Unboxing the lav mic',
        targets: const [
          PostTarget(
            platform: PlatformId.youtube,
            status: TargetStatus.scheduled,
          ),
        ],
        isDraft: true,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ),
    expect: () => [
      const ComposerState(
        draft: PostDraft(
          video: _video,
          caption: 'Unboxing the lav mic',
          platforms: {PlatformId.youtube},
        ),
        draftId: 'draft-1',
        upload: Uploaded(_video),
        hasPlatformChoice: true,
      ),
    ],
  );
}
