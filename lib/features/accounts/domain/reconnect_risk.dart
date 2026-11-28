import 'package:equatable/equatable.dart';
import 'package:pushit/domain/domain.dart';

/// The scheduled posts that fail unless an account is reconnected (C5).
final class ReconnectRisk extends Equatable {
  const new({this.postCount = 0, this.firstPostAt});

  final int postCount;

  /// When the first of them goes out; `null` when none is at risk.
  final DateTime? firstPostAt;

  bool get hasPostsAtRisk => postCount > 0 && firstPostAt != null;

  @override
  List<Object?> get props => [postCount, firstPostAt];
}

/// The posts of [posts] that [account] cannot publish as things stand:
/// targets on it still scheduled after [now], or after its sign-in expires
/// when it is about to. A healthy account puts nothing at risk.
ReconnectRisk reconnectRiskOf(
  ConnectedAccount account,
  Iterable<Post> posts, {
  required DateTime now,
}) {
  final DateTime from;
  switch (account.health) {
    case AccountHealth.connected:
      return const ReconnectRisk();
    case AccountHealth.expired:
      from = now;
    case AccountHealth.expiringSoon:
      final expiresAt = account.signInExpiresAt;
      if (expiresAt == null) return const ReconnectRisk();
      from = expiresAt.isAfter(now) ? expiresAt : now;
  }

  var count = 0;
  DateTime? first;
  for (final post in posts.where((post) => !post.isDraft)) {
    DateTime? earliest;
    for (final target in post.targets) {
      final at = target.scheduledAt;
      if (target.accountId != account.id ||
          target.status != TargetStatus.scheduled ||
          at == null ||
          at.isBefore(from)) {
        continue;
      }
      if (earliest == null || at.isBefore(earliest)) earliest = at;
    }
    if (earliest == null) continue;
    count++;
    if (first == null || earliest.isBefore(first)) first = earliest;
  }
  return ReconnectRisk(postCount: count, firstPostAt: first);
}
