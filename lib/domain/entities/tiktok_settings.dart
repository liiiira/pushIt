import 'package:equatable/equatable.dart';
import 'package:pushit/domain/enums/tiktok_privacy.dart';

/// TikTok's posting options. Privacy has no default and every switch starts
/// off, as TikTok requires.
final class TikTokSettings extends Equatable {
  const new({
    this.privacy,
    this.allowComments = false,
    this.allowDuet = false,
    this.allowStitch = false,
    this.isCommercial = false,
  });

  /// `null` until the creator chooses.
  final TikTokPrivacy? privacy;
  final bool allowComments;
  final bool allowDuet;
  final bool allowStitch;

  /// Commercial content disclosure.
  final bool isCommercial;

  TikTokSettings copyWith({
    TikTokPrivacy? Function()? privacy,
    bool? allowComments,
    bool? allowDuet,
    bool? allowStitch,
    bool? isCommercial,
  }) => TikTokSettings(
    privacy: privacy != null ? privacy() : this.privacy,
    allowComments: allowComments ?? this.allowComments,
    allowDuet: allowDuet ?? this.allowDuet,
    allowStitch: allowStitch ?? this.allowStitch,
    isCommercial: isCommercial ?? this.isCommercial,
  );

  @override
  List<Object?> get props => [
    privacy,
    allowComments,
    allowDuet,
    allowStitch,
    isCommercial,
  ];
}
