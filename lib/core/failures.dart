import 'package:equatable/equatable.dart';

/// Every failure a repository may throw. Cubits catch these and map them to
/// state; they never carry display text.
sealed class AppFailure extends Equatable implements Exception {
  const new();

  @override
  List<Object?> get props => const [];
}

/// No connection, or the server could not be reached.
final class NetworkFailure extends AppFailure {
  const new();
}

/// The requested item does not exist (any more).
final class NotFoundFailure extends AppFailure {
  const new();
}

/// A plan limit (accounts or videos this month) is reached.
final class LimitReachedFailure extends AppFailure {
  const new();
}

/// The input was rejected.
final class ValidationFailure extends AppFailure {
  const new();
}

/// Anything else. [cause] is kept for logs, never shown to the user.
final class UnknownFailure extends AppFailure {
  const new([this.cause]);

  final Object? cause;

  @override
  List<Object?> get props => [cause];
}
