import 'package:equatable/equatable.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// A suggested caption variant for one platform (D11).
final class CaptionSuggestion extends Equatable {
  const new({required this.platform, required this.text});

  final PlatformId platform;
  final String text;

  CaptionSuggestion copyWith({PlatformId? platform, String? text}) =>
      CaptionSuggestion(
        platform: platform ?? this.platform,
        text: text ?? this.text,
      );

  @override
  List<Object?> get props => [platform, text];
}
