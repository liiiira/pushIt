import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/failures.dart';

void main() {
  test('every failure is an Exception, so it can be thrown and caught', () {
    const failures = <AppFailure>[
      NetworkFailure(),
      NotFoundFailure(),
      LimitReachedFailure(),
      ValidationFailure(),
      UnknownFailure(),
    ];

    for (final failure in failures) {
      expect(failure, isA<Exception>());
      expect(() => throw failure, throwsA(same(failure)));
    }
  });

  test('failures of the same kind are equal', () {
    expect(const NetworkFailure(), const NetworkFailure());
    expect(const NetworkFailure(), isNot(const NotFoundFailure()));
  });

  test('UnknownFailure keeps its cause and compares by it', () {
    const failure = UnknownFailure('boom');

    expect(failure.cause, 'boom');
    expect(failure, const UnknownFailure('boom'));
    expect(failure, isNot(const UnknownFailure('other')));
  });

  test('the hierarchy is sealed, so switches over it are exhaustive', () {
    String kindOf(AppFailure failure) => switch (failure) {
      NetworkFailure() => 'network',
      NotFoundFailure() => 'notFound',
      LimitReachedFailure() => 'limitReached',
      ValidationFailure() => 'validation',
      UnknownFailure() => 'unknown',
    };

    expect(kindOf(const LimitReachedFailure()), 'limitReached');
  });
}
