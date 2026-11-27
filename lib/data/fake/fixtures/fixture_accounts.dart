import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/domain/domain.dart';

/// The four accounts of the designs (C1): TikTok's session has expired.
List<ConnectedAccount> fixtureAccounts(DateTime now) => [
  ConnectedAccount(
    id: FixtureIds.youtubeAccount,
    platform: PlatformId.youtube,
    handle: '@lyesmakes',
    label: 'Lyes makes',
    accountType: 'channel',
    mode: AccountMode.automatic,
    health: AccountHealth.connected,
    signInExpiresAt: now.add(const Duration(days: 120)),
  ),
  const ConnectedAccount(
    id: FixtureIds.instagramAccount,
    platform: PlatformId.instagram,
    handle: '@lyes.makes',
    label: 'Lyes makes',
    accountType: 'creator',
    mode: AccountMode.assisted,
    health: AccountHealth.connected,
  ),
  ConnectedAccount(
    id: FixtureIds.facebookAccount,
    platform: PlatformId.facebook,
    handle: 'Lyes makes, Page',
    label: 'Lyes makes, Page',
    accountType: 'page',
    mode: AccountMode.automatic,
    health: AccountHealth.connected,
    signInExpiresAt: now.add(const Duration(days: 45)),
  ),
  ConnectedAccount(
    id: FixtureIds.tiktokAccount,
    platform: PlatformId.tiktok,
    handle: '@lyes.makes',
    label: 'Lyes makes',
    accountType: 'creator',
    mode: AccountMode.assisted,
    health: AccountHealth.expired,
    signInExpiresAt: now.subtract(const Duration(days: 1)),
  ),
];

/// A newly connected account on [platform].
ConnectedAccount fixtureNewAccount({
  required String id,
  required PlatformId platform,
  required AccountMode mode,
  required DateTime now,
}) => ConnectedAccount(
  id: id,
  platform: platform,
  handle: '@lyes.makes',
  label: 'Lyes makes',
  accountType: 'creator',
  mode: mode,
  health: AccountHealth.connected,
  signInExpiresAt: now.add(const Duration(days: 60)),
);
