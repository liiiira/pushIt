import 'dart:async';

/// One mutable in-memory value that can be watched.
///
/// [watch] emits the current value first, then every change.
final class FakeStore<T> {
  new(this._value);

  T _value;
  final StreamController<T> _changes = StreamController<T>.broadcast(
    sync: true,
  );

  T get value => _value;

  set value(T newValue) {
    _value = newValue;
    _changes.add(newValue);
  }

  Stream<T> watch() => Stream.multi((controller) {
    controller.add(_value);
    final subscription = _changes.stream.listen(controller.add);
    controller.onCancel = subscription.cancel;
  });
}
