import 'dart:async';
import 'dart:math';

import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/data/fake/fixtures/fixture_media.dart';
import 'package:pushit/domain/domain.dart';

/// The fixture gallery, and a simulated upload in ten chunks. Offline, the
/// upload pauses until [resume] (D3).
final class FakeMediaRepository implements MediaRepository {
  new(this._database);

  final FakeDatabase _database;
  _UploadSession? _session;

  @override
  Future<List<GalleryItem>> gallery() => _database.load(() => fixtureGallery);

  @override
  Stream<UploadProgress> upload(String galleryItemId) {
    final item = fixtureGallery.where((i) => i.id == galleryItemId).firstOrNull;
    if (item == null) return Stream.error(const NotFoundFailure());
    _session?.cancel();
    final session = _UploadSession(
      item: item,
      tick: _database.uploadTick,
      isOffline: () => _database.isOffline,
    );
    _session = session;
    return session.stream;
  }

  @override
  Future<void> pause() => _database.act(() => _session?.pause());

  @override
  Future<void> resume() => _database.act(() => _session?.resume());

  @override
  Future<void> cancel() => _database.act(() {
    _session?.cancel();
    _session = null;
  });
}

final class _UploadSession {
  new({required this.item, required this.tick, required this.isOffline}) {
    _controller = StreamController(onListen: () => unawaited(_run()));
  }

  static const int _chunks = 10;

  final GalleryItem item;
  final Duration tick;
  final bool Function() isOffline;

  // Created in the constructor body, where `_run` can be referenced.
  late final StreamController<UploadProgress> _controller;
  int _sent = 0;
  bool _isPaused = false;
  bool _isCancelled = false;
  Completer<void>? _resumed;

  Stream<UploadProgress> get stream => _controller.stream;

  int get _total => item.sizeBytes;

  Future<void> _run() async {
    final chunk = (_total / _chunks).ceil();
    _controller.add(Uploading(sentBytes: _sent, totalBytes: _total));
    while (_sent < _total) {
      if (isOffline()) _isPaused = true;
      if (_isPaused) {
        _controller.add(Paused(sentBytes: _sent, totalBytes: _total));
        final resumed = _resumed = Completer();
        await resumed.future;
        if (_isCancelled) return;
        continue;
      }
      await Future<void>.delayed(tick);
      if (_isCancelled) return;
      if (_isPaused) continue;
      _sent = min(_total, _sent + chunk);
      _controller.add(Uploading(sentBytes: _sent, totalBytes: _total));
    }
    _controller.add(Uploaded(fixtureVideoFrom(item)));
    await _controller.close();
  }

  void pause() => _isPaused = true;

  void resume() {
    _isPaused = false;
    _resumed?.complete();
    _resumed = null;
  }

  void cancel() {
    if (_isCancelled) return;
    _isCancelled = true;
    _resumed?.complete();
    _resumed = null;
    unawaited(_controller.close());
  }
}
