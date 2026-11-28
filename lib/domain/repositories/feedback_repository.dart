import 'package:pushit/domain/enums/feedback_kind.dart';

/// Methods throw `AppFailure`.
abstract interface class FeedbackRepository {
  Future<void> send(
    FeedbackKind kind,
    String message, {
    required bool includeDeviceDetails,
  });
}
