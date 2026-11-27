import 'package:equatable/equatable.dart';
import 'package:pushit/domain/enums/account_health.dart';
import 'package:pushit/domain/enums/account_mode.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// One account on one platform, connected to pushIt.
final class ConnectedAccount extends Equatable {
  const new({
    required this.id,
    required this.platform,
    required this.handle,
    required this.label,
    required this.accountType,
    required this.mode,
    required this.health,
    this.signInExpiresAt,
  });

  final String id;
  final PlatformId platform;

  /// The platform handle, e.g. `@lyes.makes`.
  final String handle;

  /// The account's display name on the platform, e.g. `Lyes makes`.
  final String label;

  /// The platform's own account type (`channel`, `page`, `creator`, …):
  /// a key for the view to translate, not display text.
  final String accountType;
  final AccountMode mode;
  final AccountHealth health;

  /// When the platform sign-in expires; `null` when unknown.
  final DateTime? signInExpiresAt;

  bool get needsReconnect => health == AccountHealth.expired;

  ConnectedAccount copyWith({
    String? id,
    PlatformId? platform,
    String? handle,
    String? label,
    String? accountType,
    AccountMode? mode,
    AccountHealth? health,
    DateTime? Function()? signInExpiresAt,
  }) => ConnectedAccount(
    id: id ?? this.id,
    platform: platform ?? this.platform,
    handle: handle ?? this.handle,
    label: label ?? this.label,
    accountType: accountType ?? this.accountType,
    mode: mode ?? this.mode,
    health: health ?? this.health,
    signInExpiresAt: signInExpiresAt != null
        ? signInExpiresAt()
        : this.signInExpiresAt,
  );

  @override
  List<Object?> get props => [
    id,
    platform,
    handle,
    label,
    accountType,
    mode,
    health,
    signInExpiresAt,
  ];
}
