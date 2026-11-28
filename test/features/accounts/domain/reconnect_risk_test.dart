import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/accounts/accounts.dart';

final _now = DateTime(2026, 11, 12, 15, 48);
const _video = VideoAsset(
  id: 'v1',
  fileName: 'clip.mp4',
  duration: Duration(seconds: 42),
  sizeBytes: 1000,
  width: 1080,
  height: 1920,
);

ConnectedAccount _account({
  AccountHealth health = AccountHealth.expired,
  DateTime? expiresAt,
}) => ConnectedAccount(
  id: 'tiktok-1',
  platform: PlatformId.tiktok,
  handle: '@me',
  label: 'Me',
  accountType: 'creator',
  mode: AccountMode.assisted,
  health: health,
  signInExpiresAt: expiresAt,
);

Post _post(String id, List<PostTarget> targets, {bool isDraft = false}) => Post(
  id: id,
  video: _video,
  caption: id,
  isDraft: isDraft,
  createdAt: _now,
  updatedAt: _now,
  targets: targets,
);

PostTarget _target(
  DateTime at, {
  String accountId = 'tiktok-1',
  TargetStatus status = TargetStatus.scheduled,
}) => PostTarget(
  platform: PlatformId.tiktok,
  accountId: accountId,
  scheduledAt: at,
  status: status,
);

void main() {
  final today19 = DateTime(2026, 11, 12, 19);
  final tomorrow9 = DateTime(2026, 11, 13, 9);

  test('counts the scheduled posts on an expired account', () {
    final risk = reconnectRiskOf(_account(), [
      _post('later', [_target(tomorrow9)]),
      _post('first', [_target(today19)]),
    ], now: _now);

    expect(risk, ReconnectRisk(postCount: 2, firstPostAt: today19));
  });

  test('ignores other accounts, past times, other statuses and drafts', () {
    final risk = reconnectRiskOf(_account(), [
      _post('other account', [_target(today19, accountId: 'yt-1')]),
      _post('past', [_target(DateTime(2026, 11, 12, 13, 30))]),
      _post('failed', [_target(today19, status: TargetStatus.failed)]),
      _post('draft', [_target(today19)], isDraft: true),
    ], now: _now);

    expect(risk, const ReconnectRisk());
    expect(risk.hasPostsAtRisk, isFalse);
  });

  test('counts a post once, at its earliest target on the account', () {
    final risk = reconnectRiskOf(_account(), [
      _post('twice', [_target(tomorrow9), _target(today19)]),
    ], now: _now);

    expect(risk, ReconnectRisk(postCount: 1, firstPostAt: today19));
  });

  test('on an account about to expire, counts only posts after expiry', () {
    final risk = reconnectRiskOf(
      _account(
        health: AccountHealth.expiringSoon,
        expiresAt: DateTime(2026, 11, 12, 20),
      ),
      [
        _post('before', [_target(today19)]),
        _post('after', [_target(tomorrow9)]),
      ],
      now: _now,
    );

    expect(risk, ReconnectRisk(postCount: 1, firstPostAt: tomorrow9));
  });

  test('puts nothing at risk on a healthy account', () {
    final risk = reconnectRiskOf(_account(health: AccountHealth.connected), [
      _post('first', [_target(today19)]),
    ], now: _now);

    expect(risk, const ReconnectRisk());
  });
}
