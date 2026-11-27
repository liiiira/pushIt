import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:pushit/domain/entities/platform_copy.dart';
import 'package:pushit/domain/entities/schedule_choice.dart';
import 'package:pushit/domain/entities/tiktok_settings.dart';
import 'package:pushit/domain/entities/video_asset.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// What the composer (D1–D11) builds before saving or scheduling.
final class PostDraft extends Equatable {
  const new({
    this.video,
    this.caption = '',
    this._platforms = const {},
    this._copies = const [],
    this.coverAt = Duration.zero,
    this.tiktok = const TikTokSettings(),
    this.schedule,
  });

  /// `null` until the upload finishes.
  final VideoAsset? video;
  final String caption;
  final Set<PlatformId> _platforms;
  final List<PlatformCopy> _copies;
  final Duration coverAt;
  final TikTokSettings tiktok;
  final ScheduleChoice? schedule;

  Set<PlatformId> get platforms => UnmodifiableSetView(_platforms);
  List<PlatformCopy> get copies => UnmodifiableListView(_copies);

  PostDraft copyWith({
    VideoAsset? Function()? video,
    String? caption,
    Set<PlatformId>? platforms,
    List<PlatformCopy>? copies,
    Duration? coverAt,
    TikTokSettings? tiktok,
    ScheduleChoice? Function()? schedule,
  }) => PostDraft(
    video: video != null ? video() : this.video,
    caption: caption ?? this.caption,
    platforms: platforms ?? _platforms,
    copies: copies ?? _copies,
    coverAt: coverAt ?? this.coverAt,
    tiktok: tiktok ?? this.tiktok,
    schedule: schedule != null ? schedule() : this.schedule,
  );

  @override
  List<Object?> get props => [
    video,
    caption,
    _platforms,
    _copies,
    coverAt,
    tiktok,
    schedule,
  ];
}
