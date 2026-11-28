import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/activity/domain/group_activity_by_day.dart';
import 'package:pushit/features/activity/presentation/cubit/activity_cubit.dart';

import '../../../../helpers/helpers.dart';

class _MockActivity extends Mock implements ActivityRepository;

class _MockPosts extends Mock implements PostsRepository;

final _failedItem = ActivityItem(
  id: 'a1',
  kind: ActivityKind.failed,
  occurredAt: DateTime(2026, 11, 12, 13, 31),
  postId: 'mic',
  postTitle: 'Mic test',
  platform: PlatformId.tiktok,
);

Post _mic({required TargetStatus tiktok}) => Post(
  id: 'mic',
  video: const VideoAsset(
    id: 'v',
    fileName: 'v.mp4',
    duration: Duration(seconds: 38),
    sizeBytes: 1,
    width: 1080,
    height: 1920,
  ),
  caption: 'Mic test',
  isDraft: false,
  createdAt: testNow,
  updatedAt: testNow,
  targets: [
    PostTarget(
      platform: PlatformId.tiktok,
      accountId: 'tt',
      status: tiktok,
      failureReason: tiktok == TargetStatus.failed
          ? TargetFailureReason.signInExpired
          : null,
    ),
  ],
);

void main() {
  late _MockActivity activity; // fresh for each test
  late _MockPosts posts; // fresh for each test
  late StreamController<List<ActivityItem>> activityStream; // ditto
  late StreamController<List<Post>> postsStream; // ditto

  setUp(() {
    activity = _MockActivity();
    posts = _MockPosts();
    activityStream = StreamController.broadcast();
    postsStream = StreamController.broadcast();
    when(activity.watchActivity).thenAnswer((_) => activityStream.stream);
    when(posts.watchPosts).thenAnswer((_) => postsStream.stream);
    when(() => posts.retry(any(), any()))
        .thenAnswer((_) async => _mic(tiktok: TargetStatus.published));
  });

  setUpAll(() => registerFallbackValue(PlatformId.tiktok));

  ActivityCubit build() => ActivityCubit(
    activity: activity,
    posts: posts,
    clock: FixedClock(testNow),
  );

  test('loads until activity and posts have arrived, then groups', () async {
    final cubit = build()..started();
    addTearDown(cubit.close);
    await pumpEventQueue();
    expect(cubit.state.status, ViewStatus.loading);

    activityStream.add([_failedItem]);
    await pumpEventQueue();
    expect(cubit.state.status, ViewStatus.loading);

    postsStream.add([_mic(tiktok: TargetStatus.failed)]);
    await pumpEventQueue();
    expect(cubit.state.status, ViewStatus.ready);
    expect(cubit.state.groups.single.day, ActivityDay.today);
    expect(cubit.state.canRetry(_failedItem), isTrue);
    expect(
      cubit.state.failureReasonOf(_failedItem),
      TargetFailureReason.signInExpired,
    );
  });

  test('is empty without activity', () async {
    final cubit = build()..started();
    addTearDown(cubit.close);

    activityStream.add(const []);
    postsStream.add(const []);
    await pumpEventQueue();

    expect(cubit.state.status, ViewStatus.empty);
  });

  test('retries the platform; Retry goes once it is published', () async {
    final cubit = build()..started();
    addTearDown(cubit.close);
    activityStream.add([_failedItem]);
    postsStream.add([_mic(tiktok: TargetStatus.failed)]);
    await pumpEventQueue();

    final retrying = cubit.retryTapped(_failedItem);
    expect(cubit.state.isRetrying(_failedItem), isTrue);
    await retrying;
    expect(cubit.state.isRetrying(_failedItem), isFalse);
    verify(() => posts.retry('mic', PlatformId.tiktok)).called(1);

    postsStream.add([_mic(tiktok: TargetStatus.published)]);
    await pumpEventQueue();
    expect(cubit.state.canRetry(_failedItem), isFalse);
  });

  test('keeps a failed retry for one emission', () async {
    when(() => posts.retry(any(), any())).thenThrow(const NetworkFailure());
    final cubit = build()..started();
    addTearDown(cubit.close);
    activityStream.add([_failedItem]);
    postsStream.add([_mic(tiktok: TargetStatus.failed)]);
    await pumpEventQueue();
    final seen = <AppFailure?>[];
    final subscription = cubit.stream.listen((s) => seen.add(s.actionFailure));
    addTearDown(subscription.cancel);

    await cubit.retryTapped(_failedItem);
    await pumpEventQueue();

    expect(seen, contains(const NetworkFailure()));
    expect(cubit.state.actionFailure, isNull);
    expect(cubit.state.canRetry(_failedItem), isTrue);
  });

  test('shows the failure, then loads again', () async {
    final cubit = build()..started();
    addTearDown(cubit.close);

    activityStream.addError(const NetworkFailure());
    await pumpEventQueue();
    expect(cubit.state.status, ViewStatus.failure);

    cubit.reloadTapped();
    await pumpEventQueue();
    expect(cubit.state.status, ViewStatus.loading);
    verify(activity.watchActivity).called(2);
    verify(posts.watchPosts).called(2);
  });
}
