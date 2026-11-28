import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/data/dependencies.dart';
import 'package:pushit/domain/domain.dart';

/// One provider per repository interface of [dependencies], plus the
/// [Clock], typed by interface so pages read them with
/// `context.read<XRepository>()`.
List<RepositoryProvider<Object?>> repositoryProvidersOf(
  Dependencies dependencies,
) => [
  RepositoryProvider<Clock>.value(value: dependencies.clock),
  RepositoryProvider<AuthRepository>.value(value: dependencies.auth),
  RepositoryProvider<AccountsRepository>.value(value: dependencies.accounts),
  RepositoryProvider<MediaRepository>.value(value: dependencies.media),
  RepositoryProvider<PostsRepository>.value(value: dependencies.posts),
  RepositoryProvider<CaptionSuggestionsRepository>.value(
    value: dependencies.captionSuggestions,
  ),
  RepositoryProvider<ActivityRepository>.value(value: dependencies.activity),
  RepositoryProvider<SubscriptionRepository>.value(
    value: dependencies.subscription,
  ),
  RepositoryProvider<NotificationSettingsRepository>.value(
    value: dependencies.notificationSettings,
  ),
  RepositoryProvider<ReferralRepository>.value(value: dependencies.referral),
  RepositoryProvider<FeedbackRepository>.value(value: dependencies.feedback),
  RepositoryProvider<ConnectivityRepository>.value(
    value: dependencies.connectivity,
  ),
];
