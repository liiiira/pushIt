import 'package:equatable/equatable.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// A per-platform caption override (D5). [title] is used by YouTube only.
final class PlatformCopy extends Equatable {
  const new({required this.platform, required this.text, this.title});

  final PlatformId platform;
  final String? title;
  final String text;

  PlatformCopy copyWith({
    PlatformId? platform,
    String? Function()? title,
    String? text,
  }) => PlatformCopy(
    platform: platform ?? this.platform,
    title: title != null ? title() : this.title,
    text: text ?? this.text,
  );

  @override
  List<Object?> get props => [platform, title, text];
}
