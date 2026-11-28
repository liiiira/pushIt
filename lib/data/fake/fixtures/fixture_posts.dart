import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/data/fake/fixtures/fixture_media.dart';
import 'package:pushit/domain/domain.dart';

/// The posts and drafts of the designs, relative to [now].
///
/// Times follow B1, E1 and E2: Desk cable fix (Mon 12:00), Lighting test
/// (Wed 18:30), then today Morning b-roll (09:00), Mic test (13:30),
/// Studio tour, part 2 (19:00) and Behind the desk (21:00, assisted).
/// Statistics add up to B1's last 7 days: 12 480 views, 1 932 likes,
/// 214 comments.
List<Post> fixturePosts(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  DateTime at(int dayOffset, int hour, [int minute = 0]) =>
      today.add(Duration(days: dayOffset, hours: hour, minutes: minute));
  final refreshed = now.subtract(const Duration(hours: 2));
  PostStats stats(int views, int likes, int comments) => PostStats(
    views: views,
    likes: likes,
    comments: comments,
    refreshedAt: refreshed,
  );

  return [
    Post(
      id: FixtureIds.studioTour,
      video: fixtureVideo('gallery-studio-tour'),
      caption:
          'Second half of the studio tour: the desk, the lights and every '
          'cable behind them.',
      copies: const [
        PlatformCopy(
          platform: PlatformId.youtube,
          title: 'Studio tour, part 2',
          text:
              'Second half of the studio tour: the desk, the lights and '
              'every cable behind them. Part 1 is on the channel.',
        ),
      ],
      coverAt: const Duration(seconds: 4),
      tiktok: const TikTokSettings(
        privacy: TikTokPrivacy.everyone,
        allowComments: true,
      ),
      targets: [
        for (final (platform, account) in [
          (PlatformId.youtube, FixtureIds.youtubeAccount),
          (PlatformId.instagram, FixtureIds.instagramAccount),
          (PlatformId.tiktok, FixtureIds.tiktokAccount),
        ])
          PostTarget(
            platform: platform,
            accountId: account,
            scheduledAt: at(0, 19),
            status: TargetStatus.scheduled,
          ),
      ],
      isDraft: false,
      createdAt: at(0, 10),
      updatedAt: at(0, 10),
    ),
    Post(
      id: FixtureIds.micTest,
      video: fixtureVideo('gallery-mic-test'),
      caption: 'Testing the new lav mic before the next shoot.',
      copies: const [
        PlatformCopy(
          platform: PlatformId.youtube,
          title: 'Mic test',
          text: 'Testing the new lav mic before the next shoot.',
        ),
      ],
      tiktok: const TikTokSettings(privacy: TikTokPrivacy.everyone),
      targets: [
        PostTarget(
          platform: PlatformId.youtube,
          accountId: FixtureIds.youtubeAccount,
          scheduledAt: at(0, 13, 30),
          status: TargetStatus.published,
          url: Uri.parse('https://youtube.com/shorts/mictest'),
          stats: stats(452, 58, 10),
        ),
        PostTarget(
          platform: PlatformId.instagram,
          accountId: FixtureIds.instagramAccount,
          scheduledAt: at(0, 13, 30),
          status: TargetStatus.processing,
        ),
        PostTarget(
          platform: PlatformId.tiktok,
          accountId: FixtureIds.tiktokAccount,
          scheduledAt: at(0, 13, 30),
          status: TargetStatus.failed,
          failureReason: TargetFailureReason.signInExpired,
        ),
      ],
      isDraft: false,
      createdAt: at(0, 8),
      updatedAt: at(0, 13, 31),
    ),
    Post(
      id: FixtureIds.morningBroll,
      video: fixtureVideo('gallery-broll'),
      caption: 'First light in the studio, no talking.',
      copies: const [
        PlatformCopy(
          platform: PlatformId.youtube,
          title: 'Morning b-roll',
          text: 'First light in the studio, no talking.',
        ),
      ],
      tiktok: const TikTokSettings(privacy: TikTokPrivacy.everyone),
      targets: [
        PostTarget(
          platform: PlatformId.youtube,
          accountId: FixtureIds.youtubeAccount,
          scheduledAt: at(0, 9),
          status: TargetStatus.published,
          url: Uri.parse('https://youtube.com/shorts/morningbroll'),
          stats: stats(5120, 702, 60),
        ),
        PostTarget(
          platform: PlatformId.instagram,
          accountId: FixtureIds.instagramAccount,
          scheduledAt: at(0, 9),
          status: TargetStatus.published,
          url: Uri.parse('https://instagram.com/reel/morningbroll'),
          stats: stats(2344, 498, 28),
        ),
        PostTarget(
          platform: PlatformId.tiktok,
          accountId: FixtureIds.tiktokAccount,
          scheduledAt: at(0, 9),
          status: TargetStatus.published,
          url: Uri.parse('https://tiktok.com/@lyes.makes/video/morningbroll'),
          stats: stats(740, 110, 8),
        ),
      ],
      isDraft: false,
      createdAt: at(-1, 20),
      updatedAt: at(0, 9, 2),
    ),
    Post(
      id: FixtureIds.behindTheDesk,
      video: fixtureBehindTheDeskVideo,
      caption: 'Behind the desk\nWhere every edit happens.',
      targets: [
        PostTarget(
          platform: PlatformId.instagram,
          accountId: FixtureIds.instagramAccount,
          scheduledAt: at(0, 21),
          status: TargetStatus.scheduled,
        ),
      ],
      isDraft: false,
      createdAt: at(-1, 19),
      updatedAt: at(-1, 19),
    ),
    Post(
      id: FixtureIds.lightingTest,
      video: fixtureLightingTestVideo,
      caption: 'Two lights, one softbox, three looks.',
      copies: const [
        PlatformCopy(
          platform: PlatformId.youtube,
          title: 'Lighting test',
          text: 'Two lights, one softbox, three looks.',
        ),
      ],
      targets: [
        PostTarget(
          platform: PlatformId.youtube,
          accountId: FixtureIds.youtubeAccount,
          scheduledAt: at(-1, 18, 30),
          status: TargetStatus.published,
          url: Uri.parse('https://youtube.com/shorts/lightingtest'),
          stats: stats(1800, 260, 50),
        ),
        PostTarget(
          platform: PlatformId.facebook,
          accountId: FixtureIds.facebookAccount,
          scheduledAt: at(-1, 18, 30),
          status: TargetStatus.published,
          url: Uri.parse('https://facebook.com/reel/lightingtest'),
          stats: stats(810, 128, 21),
        ),
      ],
      isDraft: false,
      createdAt: at(-1, 10),
      updatedAt: at(-1, 18, 32),
    ),
    Post(
      id: FixtureIds.deskCableFix,
      video: fixtureVideo('gallery-desk-cable'),
      caption: 'Ten minutes, forty zip ties, one clean desk.',
      copies: const [
        PlatformCopy(
          platform: PlatformId.youtube,
          title: 'Desk cable fix',
          text: 'Ten minutes, forty zip ties, one clean desk.',
        ),
      ],
      targets: [
        PostTarget(
          platform: PlatformId.youtube,
          accountId: FixtureIds.youtubeAccount,
          scheduledAt: at(-3, 12),
          status: TargetStatus.published,
          url: Uri.parse('https://youtube.com/shorts/deskcablefix'),
          stats: stats(1214, 176, 37),
        ),
      ],
      isDraft: false,
      createdAt: at(-3, 9),
      updatedAt: at(-3, 12, 2),
    ),
    Post(
      id: FixtureIds.unboxingDraft,
      video: fixtureVideo('gallery-unboxing'),
      caption: 'Unboxing the lav mic',
      targets: const [
        PostTarget(
          platform: PlatformId.youtube,
          accountId: FixtureIds.youtubeAccount,
          status: TargetStatus.scheduled,
        ),
        PostTarget(
          platform: PlatformId.instagram,
          accountId: FixtureIds.instagramAccount,
          status: TargetStatus.scheduled,
        ),
      ],
      isDraft: true,
      createdAt: now.subtract(const Duration(hours: 2)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    ),
    Post(
      id: FixtureIds.qaDraft,
      video: fixtureVideo('gallery-qa'),
      caption: 'Q&A, short cut',
      tiktok: const TikTokSettings(),
      targets: const [
        PostTarget(
          platform: PlatformId.youtube,
          accountId: FixtureIds.youtubeAccount,
          status: TargetStatus.scheduled,
        ),
        PostTarget(
          platform: PlatformId.instagram,
          accountId: FixtureIds.instagramAccount,
          status: TargetStatus.scheduled,
        ),
        PostTarget(
          platform: PlatformId.tiktok,
          accountId: FixtureIds.tiktokAccount,
          status: TargetStatus.scheduled,
        ),
      ],
      isDraft: true,
      createdAt: at(-1, 16),
      updatedAt: at(-1, 16),
    ),
  ];
}

/// The videos the populated data counts as scheduled this month.
const int fixturePostsThisMonth = 6;

/// The public link of a post that the fakes publish.
Uri fixturePostUrl(PlatformId platform, String postId) =>
    Uri.parse('https://example.com/${platform.name}/$postId');
