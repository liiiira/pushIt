import 'package:equatable/equatable.dart';
import 'package:pushit/domain/enums/delete_method.dart';
import 'package:pushit/domain/enums/deletion_outcome.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// The progress of "delete everywhere" (F7) on one platform.
final class DeletionStep extends Equatable {
  const new({
    required this.platform,
    required this.method,
    required this.outcome,
  });

  final PlatformId platform;
  final DeleteMethod method;
  final DeletionOutcome outcome;

  DeletionStep copyWith({
    PlatformId? platform,
    DeleteMethod? method,
    DeletionOutcome? outcome,
  }) => DeletionStep(
    platform: platform ?? this.platform,
    method: method ?? this.method,
    outcome: outcome ?? this.outcome,
  );

  @override
  List<Object?> get props => [platform, method, outcome];
}
