import 'package:equatable/equatable.dart';

final class PostStats extends Equatable {
  const new({
    required this.views,
    required this.likes,
    required this.comments,
    required this.refreshedAt,
  });

  final int views;
  final int likes;
  final int comments;
  final DateTime refreshedAt;

  /// The sum of both, refreshed at the later of the two times.
  PostStats operator +(PostStats other) => PostStats(
    views: views + other.views,
    likes: likes + other.likes,
    comments: comments + other.comments,
    refreshedAt: refreshedAt.isAfter(other.refreshedAt)
        ? refreshedAt
        : other.refreshedAt,
  );

  PostStats copyWith({
    int? views,
    int? likes,
    int? comments,
    DateTime? refreshedAt,
  }) => PostStats(
    views: views ?? this.views,
    likes: likes ?? this.likes,
    comments: comments ?? this.comments,
    refreshedAt: refreshedAt ?? this.refreshedAt,
  );

  @override
  List<Object?> get props => [views, likes, comments, refreshedAt];
}
