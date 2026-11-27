import 'package:equatable/equatable.dart';
import 'package:pushit/domain/enums/edit_outcome.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// What "edit everywhere" (F5) did on one platform.
final class EditResult extends Equatable {
  const new({required this.platform, required this.outcome});

  final PlatformId platform;
  final EditOutcome outcome;

  EditResult copyWith({PlatformId? platform, EditOutcome? outcome}) =>
      EditResult(
        platform: platform ?? this.platform,
        outcome: outcome ?? this.outcome,
      );

  @override
  List<Object?> get props => [platform, outcome];
}
