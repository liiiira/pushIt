import 'dart:collection';

import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/domain/domain.dart';

typedef SentFeedback = ({
  FeedbackKind kind,
  String message,
  bool includeDeviceDetails,
});

/// Records what is sent, so tests can check it.
final class FakeFeedbackRepository implements FeedbackRepository {
  new(this._database);

  final FakeDatabase _database;
  final List<SentFeedback> _sent = [];

  List<SentFeedback> get sent => UnmodifiableListView(_sent);

  @override
  Future<void> send(
    FeedbackKind kind,
    String message, {
    required bool includeDeviceDetails,
  }) => _database.act(() {
    if (message.trim().isEmpty) throw const ValidationFailure();
    _sent.add((
      kind: kind,
      message: message,
      includeDeviceDetails: includeDeviceDetails,
    ));
  });
}
