import 'package:equatable/equatable.dart';
import 'package:pushit/domain/entities/video_asset.dart';

/// Events of `MediaRepository.upload` (D2, D3).
sealed class UploadProgress extends Equatable {
  const new();

  @override
  List<Object?> get props => const [];
}

final class Uploading extends UploadProgress {
  const new({required this.sentBytes, required this.totalBytes});

  final int sentBytes;
  final int totalBytes;

  /// From 0 to 1.
  double get fraction => totalBytes == 0 ? 0 : sentBytes / totalBytes;

  @override
  List<Object?> get props => [sentBytes, totalBytes];
}

final class Paused extends UploadProgress {
  const new({required this.sentBytes, required this.totalBytes});

  final int sentBytes;
  final int totalBytes;

  /// From 0 to 1.
  double get fraction => totalBytes == 0 ? 0 : sentBytes / totalBytes;

  @override
  List<Object?> get props => [sentBytes, totalBytes];
}

final class UploadFailed extends UploadProgress {
  const new();
}

final class Uploaded extends UploadProgress {
  const new(this.video);

  final VideoAsset video;

  @override
  List<Object?> get props => [video];
}
