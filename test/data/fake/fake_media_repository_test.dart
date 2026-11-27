import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_media_repository.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

import 'fake_support.dart';

void main() {
  for (final scenario in Scenario.values) {
    group(scenario.name, () {
      late FakeMediaRepository repository; // set up fresh for each test

      setUp(() => repository = FakeMediaRepository(fakeDatabase(scenario)));

      test('gallery', () async {
        final gallery = repository.gallery();
        if (scenario == Scenario.error) {
          await expectLater(gallery, throwsA(isA<NetworkFailure>()));
          return;
        }
        final items = await gallery;
        expect(items.map((i) => i.duration.inSeconds), [
          102,
          38,
          59,
          130,
          21,
          65,
        ]);
        expect(items.first.fileName, 'studio_tour_p2.mp4');
        expect(items.first.sizeBytes, 300 * 1024 * 1024);
      });

      if (scenario == Scenario.offline) {
        test('upload pauses for lack of connection', () async {
          final events = await repository
              .upload('gallery-studio-tour')
              .take(2)
              .toList();
          expect(events.first, isA<Uploading>());
          expect(events.last, isA<Paused>());
        });
        return;
      }

      test('upload reports progress, then the uploaded video', () async {
        final events = await repository.upload('gallery-broll').toList();
        expect(events.first, isA<Uploading>());
        final progress = events.whereType<Uploading>().map((e) => e.sentBytes);
        expect(progress, orderedEquals([...progress]..sort()));
        final last = events.last as Uploaded;
        expect(last.video.fileName, 'morning_broll.mp4');
        expect(last.video.duration, const Duration(seconds: 38));
      });

      test('pause stops the upload until resume', () async {
        final events = <UploadProgress>[];
        final done = Completer<void>();
        repository
            .upload('gallery-broll')
            .listen(events.add, onDone: done.complete);
        await pumpEventQueue(times: 2);

        await repository.pause();
        await pumpEventQueue();
        expect(events.last, isA<Paused>());
        final pausedCount = events.length;
        await pumpEventQueue();
        expect(events, hasLength(pausedCount), reason: 'no progress paused');

        await repository.resume();
        await done.future;
        expect(events.last, isA<Uploaded>());
      });

      test('cancel ends the upload without a video', () async {
        final events = <UploadProgress>[];
        final done = Completer<void>();
        repository
            .upload('gallery-broll')
            .listen(events.add, onDone: done.complete);
        await pumpEventQueue(times: 2);
        await repository.cancel();
        await done.future;
        expect(events.whereType<Uploaded>(), isEmpty);
      });

      test('an unknown gallery item fails', () async {
        await expectLater(
          repository.upload('missing').first,
          throwsA(isA<NotFoundFailure>()),
        );
      });
    });
  }
}
