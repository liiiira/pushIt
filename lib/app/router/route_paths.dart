/// Relative segments of nested routes, used when declaring `GoRoute`s.
///
/// Navigate with [RoutePaths], never with these.
abstract final class RouteSegments {
  static const activity = 'activity';
  static const addAccount = 'add';
  static const accountId = 'accountId';
  static const accountDetail = ':$accountId';

  static const upload = 'upload';
  static const post = 'post';
  static const captions = 'captions';
  static const cover = 'cover';
  static const tiktok = 'tiktok';
  static const check = 'check';
  static const drafts = 'drafts';
  static const scheduled = 'scheduled';

  static const postId = 'postId';
  static const libraryPost = ':$postId';
  static const edit = 'edit';
  static const delete = 'delete';
  static const result = 'result';

  static const platform = 'platform';

  static const plans = 'plans';
  static const notifications = 'notifications';
  static const invite = 'invite';
  static const feedback = 'feedback';
  static const appearance = 'appearance';
  static const developer = 'developer';
}

/// Every route of the app (docs/SCREENS.md). Bottom sheets and dialogs are
/// not routes.
abstract final class RoutePaths {
  static const root = '/';

  // A: splash, onboarding and auth.
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const resetPassword = '/reset-password';

  // B: home and activity.
  static const home = '/home';
  static const activity = '$home/${RouteSegments.activity}';

  // C: accounts.
  static const accounts = '/accounts';
  static const addAccount = '$accounts/${RouteSegments.addAccount}';
  static const accountDetail = '$accounts/${RouteSegments.accountDetail}';

  // D: composer (full screen, outside the tabs).
  static const compose = '/compose';
  static const composeUpload = '$compose/${RouteSegments.upload}';
  static const composePost = '$compose/${RouteSegments.post}';
  static const composePostCaptions = '$composePost/${RouteSegments.captions}';
  static const composePostCover = '$composePost/${RouteSegments.cover}';
  static const composePostTikTok = '$composePost/${RouteSegments.tiktok}';
  static const composePostCheck = '$composePost/${RouteSegments.check}';
  static const composeDrafts = '$compose/${RouteSegments.drafts}';
  static const composeScheduled = '$compose/${RouteSegments.scheduled}';

  // E: calendar.
  static const calendar = '/calendar';

  // F: library and post.
  static const library = '/library';
  static const libraryPost = '$library/${RouteSegments.libraryPost}';
  static const libraryPostEdit = '$libraryPost/${RouteSegments.edit}';
  static const libraryPostDelete = '$libraryPost/${RouteSegments.delete}';
  static const libraryPostDeleteResult =
      '$libraryPostDelete/${RouteSegments.result}';

  // G: assisted posting.
  static const assisted =
      '/assisted/:${RouteSegments.postId}/:${RouteSegments.platform}';
  static const assistedDelete = '$assisted/${RouteSegments.delete}';

  // H: settings and plans.
  static const settings = '/settings';
  static const plans = '$settings/${RouteSegments.plans}';
  static const notificationSettings =
      '$settings/${RouteSegments.notifications}';
  static const invite = '$settings/${RouteSegments.invite}';
  static const feedback = '$settings/${RouteSegments.feedback}';
  static const appearance = '$settings/${RouteSegments.appearance}';

  // Debug builds only.
  static const developer = '$settings/${RouteSegments.developer}';
  static const devComponents = '/dev/components';

  static String accountDetailFor(String accountId) =>
      '$accounts/${_encode(accountId)}';

  static String libraryPostFor(String postId) => '$library/${_encode(postId)}';

  static String libraryPostEditFor(String postId) =>
      '${libraryPostFor(postId)}/${RouteSegments.edit}';

  static String libraryPostDeleteFor(String postId) =>
      '${libraryPostFor(postId)}/${RouteSegments.delete}';

  static String libraryPostDeleteResultFor(String postId) =>
      '${libraryPostDeleteFor(postId)}/${RouteSegments.result}';

  /// [platform] is the `PlatformId` name, e.g. `tiktok`.
  static String assistedFor(String postId, String platform) =>
      '/assisted/${_encode(postId)}/${_encode(platform)}';

  static String assistedDeleteFor(String postId, String platform) =>
      '${assistedFor(postId, platform)}/${RouteSegments.delete}';

  static String _encode(String value) => Uri.encodeComponent(value);
}
