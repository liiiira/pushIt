import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_activity_repository.dart';
import 'package:pushit/data/fake/fake_posts_repository.dart';
import 'package:pushit/data/fake/fake_subscription_repository.dart';
import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

import 'fake_support.dart';

const _video = VideoAsset(
  id: 'video-new',
  fileName: 'new.mp4',
  duration: Duration(seconds: 30),
  sizeBytes: 10 * 1024 * 1024,
  width: 1080,
  height: 1920,
);

PostDraft _draft({ScheduleChoice? schedule}) => PostDraft(
  video: _video,
  caption: 'Desk tour, the sequel',
  platforms: const {PlatformId.youtube, PlatformId.instagram},
  schedule: schedule,
);

Future<Post> _post(FakePostsRepository repository, String id) =>
    repository.watchPost(id).first;

void main() {
  for (final scenario in Scenario.values) {
    group(scenario.name, () {
      late FakePostsRepository repository; // set up fresh for each test

      setUp(() => repository = FakePostsRepository(fakeDatabase(scenario)));

      if (scenario == Scenario.error) {
        test('list loads fail with a network failure', () async {
          await expectLater(
            repository.watchPosts().first,
            throwsA(isA<NetworkFailure>()),
          );
          await expectLater(
            repository.watchPost(FixtureIds.studioTour).first,
            throwsA(isA<NetworkFailure>()),
          );
        });
        return;
      }

      if (scenario == Scenario.firstUse) {
        test('there are no posts', () async {
          expect(await repository.watchPosts().first, isEmpty);
        });
      } else {
        group('fixtures', () {
          test('six posts and two drafts, newest first', () async {
            final posts = await repository.watchPosts().first;
            expect(posts.where((p) => !p.isDraft).map((p) => p.title), [
              'Studio tour, part 2',
              'Mic test',
              'Morning b-roll',
              'Behind the desk',
              'Lighting test',
              'Desk cable fix',
            ]);
            expect(posts.where((p) => p.isDraft).map((p) => p.title), {
              'Unboxing the lav mic',
              'Q&A, short cut',
            });
            final created = posts.map((p) => p.createdAt).toList();
            expect(created, [...created]..sort((a, b) => b.compareTo(a)));
          });

          test('Studio tour: today 19:00 on three platforms', () async {
            final post = await _post(repository, FixtureIds.studioTour);
            expect(post.status, PostStatus.scheduled);
            expect(post.nextScheduledAt, today(19));
            expect(
              post.nextScheduledAt!.difference(testNow),
              const Duration(hours: 3, minutes: 12),
            );
            expect(
              post.video.duration,
              const Duration(minutes: 1, seconds: 42),
            );
            expect(post.targets.map((t) => t.platform), [
              PlatformId.youtube,
              PlatformId.instagram,
              PlatformId.tiktok,
            ]);
          });

          test('Mic test failed on TikTok at 13:30', () async {
            final post = await _post(repository, FixtureIds.micTest);
            final tiktok = post.targetFor(PlatformId.tiktok)!;
            expect(post.status, PostStatus.partiallyFailed);
            expect(tiktok.status, TargetStatus.failed);
            expect(tiktok.failureReason, TargetFailureReason.signInExpired);
            expect(tiktok.scheduledAt, today(13, 30));
            expect(
              post.targetFor(PlatformId.instagram)!.status,
              TargetStatus.processing,
            );
          });

          test('Morning b-roll: published 09:00, 8 204 views', () async {
            final post = await _post(repository, FixtureIds.morningBroll);
            expect(post.status, PostStatus.published);
            expect(post.totals!.views, 8204);
            expect(post.totals!.likes, 1310);
            expect(post.totals!.comments, 96);
            expect(post.totals!.refreshedAt, today(13, 48));
            expect(post.caption, 'First light in the studio, no talking.');
          });

          test('Behind the desk: assisted on Instagram at 21:00', () async {
            final post = await _post(repository, FixtureIds.behindTheDesk);
            expect(post.targets.single.platform, PlatformId.instagram);
            expect(post.nextScheduledAt, today(21));
          });
        });
      }

      test('watchPost fails for an unknown post', () async {
        await expectLater(
          repository.watchPost('missing').first,
          throwsA(isA<NotFoundFailure>()),
        );
      });

      group('drafts', () {
        test('saveDraft needs a video', () async {
          await expectLater(
            repository.saveDraft(const PostDraft(caption: 'x')),
            throwsA(isA<ValidationFailure>()),
          );
        });

        test('saveDraft creates, then updates a draft', () async {
          final draft = await repository.saveDraft(_draft());
          expect(draft.isDraft, isTrue);
          expect(draft.status, PostStatus.draft);
          expect(draft.createdAt, testNow);
          expect(draft.targets.map((t) => t.scheduledAt), [null, null]);

          final updated = await repository.saveDraft(
            _draft().copyWith(caption: 'Changed'),
            draftId: draft.id,
          );
          expect(updated.id, draft.id);
          expect(updated.caption, 'Changed');
          final drafts = (await repository.watchPosts().first).where(
            (p) => p.id == draft.id,
          );
          expect(drafts, [updated]);
        });

        test('discardDraft removes it', () async {
          final draft = await repository.saveDraft(_draft());
          await repository.discardDraft(draft.id);
          await expectLater(
            _post(repository, draft.id),
            throwsA(isA<NotFoundFailure>()),
          );
        });
      });

      group('schedule', () {
        test('creates a post with a target per platform', () async {
          final draft = await repository.saveDraft(_draft());
          final schedule = repository.schedule(
            _draft(schedule: SameTime(today(20))),
            draftId: draft.id,
          );
          if (scenario == Scenario.freeLimit) {
            await expectLater(schedule, throwsA(isA<LimitReachedFailure>()));
            return;
          }
          final post = await schedule;
          expect(post.isDraft, isFalse);
          expect(post.status, PostStatus.scheduled);
          expect(post.targets.map((t) => (t.platform, t.scheduledAt)), [
            (PlatformId.youtube, today(20)),
            (PlatformId.instagram, today(20)),
          ]);
          await expectLater(
            _post(repository, draft.id),
            throwsA(isA<NotFoundFailure>()),
            reason: 'the draft is consumed',
          );
        });

        if (scenario != Scenario.freeLimit) {
          test("counts toward this month's usage", () async {
            final database = fakeDatabase(scenario);
            final posts = FakePostsRepository(database);
            final subscription = FakeSubscriptionRepository(database);
            final before = await subscription.watchUsage().first;
            await posts.schedule(_draft(schedule: SameTime(today(20))));
            final after = await subscription.watchUsage().first;
            expect(after.postsThisMonth, before.postsThisMonth + 1);
          });

          test('rejects a missing or past schedule', () async {
            await expectLater(
              repository.schedule(_draft()),
              throwsA(isA<ValidationFailure>()),
            );
            await expectLater(
              repository.schedule(_draft(schedule: SameTime(today(9)))),
              throwsA(isA<ValidationFailure>()),
            );
          });
        }
      });

      if (scenario == Scenario.firstUse) return;

      group('reschedule and cancel', () {
        test('reschedule moves a post that has not started', () async {
          final post = await repository.reschedule(
            FixtureIds.studioTour,
            SameTime(today(22)),
          );
          expect(post.nextScheduledAt, today(22));
          expect(
            (await _post(repository, FixtureIds.studioTour)).nextScheduledAt,
            today(22),
          );
        });

        test('reschedule and cancel refuse a started post', () async {
          await expectLater(
            repository.reschedule(FixtureIds.micTest, SameTime(today(22))),
            throwsA(isA<ValidationFailure>()),
          );
          await expectLater(
            repository.cancel(FixtureIds.morningBroll),
            throwsA(isA<ValidationFailure>()),
          );
        });

        test('cancel removes a scheduled post', () async {
          await repository.cancel(FixtureIds.studioTour);
          await expectLater(
            _post(repository, FixtureIds.studioTour),
            throwsA(isA<NotFoundFailure>()),
          );
        });
      });

      test('retry publishes a failed platform', () async {
        final post = await repository.retry(
          FixtureIds.micTest,
          PlatformId.tiktok,
        );
        final tiktok = post.targetFor(PlatformId.tiktok)!;
        expect(tiktok.status, TargetStatus.published);
        expect(tiktok.failureReason, isNull);
        expect(tiktok.url, isNotNull);
        await expectLater(
          repository.retry(FixtureIds.morningBroll, PlatformId.youtube),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('editEverywhere applies where platforms allow it', () async {
        final results = await repository.editEverywhere(
          FixtureIds.morningBroll,
          title: 'Morning light',
          caption: 'New caption',
        );
        expect(results, const [
          EditResult(
            platform: PlatformId.youtube,
            outcome: EditOutcome.applied,
          ),
          EditResult(
            platform: PlatformId.instagram,
            outcome: EditOutcome.notSupported,
          ),
          EditResult(
            platform: PlatformId.tiktok,
            outcome: EditOutcome.notSupported,
          ),
        ]);
        final post = await _post(repository, FixtureIds.morningBroll);
        expect(post.title, 'Morning light');
        expect(post.caption, 'New caption');
        expect(post.updatedAt, testNow);
      });

      group('deleteEverywhere', () {
        test(
          'automatic platforms go, assisted ones wait for the creator',
          () async {
            final steps = <List<DeletionStep>>[];
            final done = Completer<void>();
            repository
                .deleteEverywhere(FixtureIds.morningBroll)
                .listen(steps.add, onDone: done.complete);
            await pumpEventQueue();

            expect(
              steps.first.map((s) => s.outcome),
              everyElement(DeletionOutcome.pending),
            );
            final automaticOutcome = scenario == Scenario.offline
                ? DeletionOutcome.failed
                : DeletionOutcome.removed;
            expect(steps.last, [
              DeletionStep(
                platform: PlatformId.youtube,
                method: DeleteMethod.automatic,
                outcome: automaticOutcome,
              ),
              const DeletionStep(
                platform: PlatformId.instagram,
                method: DeleteMethod.assisted,
                outcome: DeletionOutcome.awaitingUser,
              ),
              const DeletionStep(
                platform: PlatformId.tiktok,
                method: DeleteMethod.assisted,
                outcome: DeletionOutcome.awaitingUser,
              ),
            ]);
            expect(done.isCompleted, isFalse);

            await repository.confirmAssisted(
              FixtureIds.morningBroll,
              PlatformId.instagram,
            );
            await repository.confirmAssisted(
              FixtureIds.morningBroll,
              PlatformId.tiktok,
            );
            await done.future;
            expect(
              steps.last.skip(1).map((s) => s.outcome),
              everyElement(DeletionOutcome.removed),
            );
            if (scenario != Scenario.offline) {
              await expectLater(
                _post(repository, FixtureIds.morningBroll),
                throwsA(isA<NotFoundFailure>()),
              );
            }
          },
        );
      });

      group('assisted posting', () {
        test('confirmAssisted publishes and logs it', () async {
          final database = fakeDatabase(scenario);
          final posts = FakePostsRepository(database);
          await posts.confirmAssisted(
            FixtureIds.behindTheDesk,
            PlatformId.instagram,
          );
          final post = await _post(posts, FixtureIds.behindTheDesk);
          expect(post.status, PostStatus.published);
          final activity = await FakeActivityRepository(database)
              .watchActivity()
              .first;
          expect(activity.first.kind, ActivityKind.assistedConfirmed);
          expect(activity.first.postId, FixtureIds.behindTheDesk);
        });

        test('snoozeAssisted reminds again later', () async {
          await repository.snoozeAssisted(
            FixtureIds.behindTheDesk,
            PlatformId.instagram,
            const Duration(minutes: 30),
          );
          final post = await _post(repository, FixtureIds.behindTheDesk);
          final target = post.targetFor(PlatformId.instagram)!;
          expect(target.status, TargetStatus.scheduled);
          expect(target.scheduledAt, testNow.add(const Duration(minutes: 30)));
        });

        test('triggerAssistedReminder waits for the creator', () async {
          final database = fakeDatabase(scenario);
          final posts = FakePostsRepository(database);
          await posts.triggerAssistedReminder(
            FixtureIds.behindTheDesk,
            PlatformId.instagram,
          );
          final post = await _post(posts, FixtureIds.behindTheDesk);
          expect(
            post.targetFor(PlatformId.instagram)!.status,
            TargetStatus.awaitingUser,
          );
          final activity = await FakeActivityRepository(database)
              .watchActivity()
              .first;
          expect(activity.first.kind, ActivityKind.assistedReminder);
        });
      });
    });
  }
}
