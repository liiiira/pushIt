import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:pushit/domain/entities/platform_copy.dart';
import 'package:pushit/domain/entities/post_stats.dart';
import 'package:pushit/domain/entities/post_target.dart';
import 'package:pushit/domain/entities/tiktok_settings.dart';
import 'package:pushit/domain/entities/video_asset.dart';
import 'package:pushit/domain/enums/platform_id.dart';
import 'package:pushit/domain/enums/post_status.dart';
import 'package:pushit/domain/enums/target_status.dart';
import 'package:pushit/domain/rules/post_status.dart';

/// One video and everywhere it goes. pushIt's record of truth.
final class Post extends Equatable {
  const new({
    required this.id,
    required this.video,
    required this.caption,
    required this.isDraft,
    required this.createdAt,
    required this.updatedAt,
    this._copies = const [],
    this._targets = const [],
    this.coverAt = Duration.zero,
    this.tiktok,
  });

  final String id;
  final VideoAsset video;

  /// The shared caption; [copies] override it per platform.
  final String caption;
  final List<PlatformCopy> _copies;

  /// Position of the cover frame in the video (D6).
  final Duration coverAt;

  /// `null` when TikTok is not a target.
  final TikTokSettings? tiktok;
  final List<PostTarget> _targets;
  final bool isDraft;
  final DateTime createdAt;
  final DateTime updatedAt;

  List<PlatformCopy> get copies => UnmodifiableListView(_copies);
  List<PostTarget> get targets => UnmodifiableListView(_targets);

  PostStatus get status =>
      derivePostStatus(isDraft: isDraft, targets: _targets);

  /// The earliest time a target is still scheduled for, if any.
  DateTime? get nextScheduledAt {
    DateTime? next;
    for (final target in _targets) {
      final at = target.scheduledAt;
      if (target.status != TargetStatus.scheduled || at == null) continue;
      if (next == null || at.isBefore(next)) next = at;
    }
    return next;
  }

  /// Stats summed over every target that has some; `null` when none has.
  PostStats? get totals {
    PostStats? sum;
    for (final stats in _targets.map((t) => t.stats).nonNulls) {
      sum = sum == null ? stats : sum + stats;
    }
    return sum;
  }

  /// The name lists show: the YouTube title when set, otherwise the first
  /// line of the caption. Creator data, not app text.
  String get title {
    final youtubeTitle = copyFor(PlatformId.youtube)?.title?.trim();
    if (youtubeTitle != null && youtubeTitle.isNotEmpty) return youtubeTitle;
    return caption.split('\n').first.trim();
  }

  PlatformCopy? copyFor(PlatformId platform) =>
      _copies.where((c) => c.platform == platform).firstOrNull;

  /// The text this platform gets: its override, or the shared caption.
  String captionFor(PlatformId platform) => copyFor(platform)?.text ?? caption;

  PostTarget? targetFor(PlatformId platform) =>
      _targets.where((t) => t.platform == platform).firstOrNull;

  Post copyWith({
    String? id,
    VideoAsset? video,
    String? caption,
    List<PlatformCopy>? copies,
    Duration? coverAt,
    TikTokSettings? Function()? tiktok,
    List<PostTarget>? targets,
    bool? isDraft,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Post(
    id: id ?? this.id,
    video: video ?? this.video,
    caption: caption ?? this.caption,
    copies: copies ?? _copies,
    coverAt: coverAt ?? this.coverAt,
    tiktok: tiktok != null ? tiktok() : this.tiktok,
    targets: targets ?? _targets,
    isDraft: isDraft ?? this.isDraft,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    video,
    caption,
    _copies,
    coverAt,
    tiktok,
    _targets,
    isDraft,
    createdAt,
    updatedAt,
  ];
}
