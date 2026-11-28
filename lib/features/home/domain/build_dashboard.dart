import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/accounts/accounts.dart';

/// What Home shows (B1, B2).
final class Dashboard extends Equatable {
  const new({
    required this.accountCount,
    this.next,
    this.reconnects = const [],
    this.lastSevenDays,
    this.firstUse,
  });

  /// The next post to go out; `null` when nothing is to come.
  final NextPost? next;

  /// Signed-out accounts, each with the posts it puts at risk.
  final List<ReconnectAlert> reconnects;

  /// What was published in the last 7 days; `null` when the plan has no
  /// statistics.
  final PostStats? lastSevenDays;
  final int accountCount;

  /// Set until the first post exists (B2).
  final FirstUse? firstUse;

  @override
  List<Object?> get props => [
    next,
    reconnects,
    lastSevenDays,
    accountCount,
    firstUse,
  ];
}

final class NextPost extends Equatable {
  const new({
    required this.post,
    required this.at,
    required this.day,
    required this.countdown,
  });

  final Post post;
  final DateTime at;

  /// "Next post · today".
  final RelativeDay day;

  /// "in 3 h 12 min".
  final Countdown countdown;

  @override
  List<Object?> get props => [post, at, day, countdown];
}

/// A time to wait, in whole days, hours and minutes.
final class Countdown extends Equatable {
  const new({this.days = 0, this.hours = 0, this.minutes = 0});

  /// [left], rounded up to the minute and at least one minute, so it never
  /// reads "in 0 min".
  factory until(Duration left) {
    final minutes = math.max(1, (left.inSeconds + 59) ~/ 60);
    return Countdown(
      days: minutes ~/ (24 * 60),
      hours: minutes ~/ 60 % 24,
      minutes: minutes % 60,
    );
  }

  final int days;
  final int hours;
  final int minutes;

  @override
  List<Object?> get props => [days, hours, minutes];
}

final class ReconnectAlert extends Equatable {
  const new({required this.account, required this.risk});

  final ConnectedAccount account;
  final ReconnectRisk risk;

  @override
  List<Object?> get props => [account, risk];
}

/// B2's three steps: the account is created; the next ones are connecting
/// an account and scheduling a video.
final class FirstUse extends Equatable {
  const new({required this.hasAccount});

  final bool hasAccount;

  @override
  List<Object?> get props => [hasAccount];
}

/// Builds Home from the posts, accounts and plan at `now`.
///
/// - It is a first use until a post (not a draft) exists.
/// - The next post is the earliest target still scheduled at or after now.
/// - The last 7 days add up the statistics of targets published in the 7
///   days up to now, on plans with statistics only.
final class BuildDashboard {
  const new();

  static const statisticsWindow = Duration(days: 7);

  Dashboard call({
    required List<Post> posts,
    required List<ConnectedAccount> accounts,
    required Plan plan,
    required DateTime now,
  }) {
    final live = posts.where((post) => !post.isDraft).toList();
    return Dashboard(
      next: _nextOf(live, now),
      reconnects: [
        for (final account in accounts.where((a) => a.needsReconnect))
          ReconnectAlert(
            account: account,
            risk: reconnectRiskOf(account, live, now: now),
          ),
      ],
      lastSevenDays: plan.hasStatistics ? _lastSevenDays(live, now) : null,
      accountCount: accounts.length,
      firstUse: live.isEmpty ? FirstUse(hasAccount: accounts.isNotEmpty) : null,
    );
  }

  NextPost? _nextOf(List<Post> posts, DateTime now) {
    (Post, DateTime)? next;
    for (final post in posts) {
      for (final target in post.targets) {
        final at = target.scheduledAt;
        if (target.status != TargetStatus.scheduled ||
            at == null ||
            at.isBefore(now)) {
          continue;
        }
        if (next == null || at.isBefore(next.$2)) next = (post, at);
      }
    }
    if (next == null) return null;
    final (post, at) = next;
    return NextPost(
      post: post,
      at: at,
      day: relativeDayOf(at, now: now),
      countdown: Countdown.until(at.difference(now)),
    );
  }

  PostStats _lastSevenDays(List<Post> posts, DateTime now) {
    final from = now.subtract(statisticsWindow);
    var total = PostStats(views: 0, likes: 0, comments: 0, refreshedAt: now);
    for (final target in posts.expand((post) => post.targets)) {
      final at = target.scheduledAt;
      final stats = target.stats;
      if (target.status != TargetStatus.published ||
          stats == null ||
          at == null ||
          !at.isAfter(from) ||
          at.isAfter(now)) {
        continue;
      }
      total = PostStats(
        views: total.views + stats.views,
        likes: total.likes + stats.likes,
        comments: total.comments + stats.comments,
        refreshedAt: now,
      );
    }
    return total;
  }
}
