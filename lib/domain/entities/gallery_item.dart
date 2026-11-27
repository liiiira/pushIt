import 'package:equatable/equatable.dart';

/// A video on the device, before upload.
final class GalleryItem extends Equatable {
  const new({
    required this.id,
    required this.fileName,
    required this.duration,
    required this.sizeBytes,
    required this.width,
    required this.height,
  });

  final String id;
  final String fileName;
  final Duration duration;
  final int sizeBytes;
  final int width;
  final int height;

  GalleryItem copyWith({
    String? id,
    String? fileName,
    Duration? duration,
    int? sizeBytes,
    int? width,
    int? height,
  }) => GalleryItem(
    id: id ?? this.id,
    fileName: fileName ?? this.fileName,
    duration: duration ?? this.duration,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    width: width ?? this.width,
    height: height ?? this.height,
  );

  @override
  List<Object?> get props => [id, fileName, duration, sizeBytes, width, height];
}
