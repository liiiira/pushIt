import 'package:equatable/equatable.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// Something that stops a draft from being scheduled (D8).
sealed class PlatformCheckIssue extends Equatable {
  const new();

  @override
  List<Object?> get props => const [];
}

final class DurationTooLong extends PlatformCheckIssue {
  const new({
    required this.platform,
    required this.limit,
    required this.actual,
  });

  final PlatformId platform;
  final Duration limit;
  final Duration actual;

  @override
  List<Object?> get props => [platform, limit, actual];
}

final class FileTooLarge extends PlatformCheckIssue {
  const new({required this.limitBytes, required this.actualBytes});

  final int limitBytes;
  final int actualBytes;

  @override
  List<Object?> get props => [limitBytes, actualBytes];
}

/// TikTok is selected and no privacy is chosen.
final class PrivacyNotChosen extends PlatformCheckIssue {
  const new();
}

/// No usable account (missing, or its sign-in expired).
final class NotConnected extends PlatformCheckIssue {
  const new(this.platform);

  final PlatformId platform;

  @override
  List<Object?> get props => [platform];
}

final class PaidPlanRequired extends PlatformCheckIssue {
  const new(this.platform);

  final PlatformId platform;

  @override
  List<Object?> get props => [platform];
}
