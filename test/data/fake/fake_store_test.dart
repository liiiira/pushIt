import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/data/fake/fake_store.dart';

void main() {
  test('watch emits the current value, then every change', () async {
    final store = FakeStore(1);
    final values = <int>[];
    final subscription = store.watch().listen(values.add);
    await pumpEventQueue();

    store
      ..value = 2
      ..value = 3;
    await pumpEventQueue();

    expect(values, [1, 2, 3]);
    expect(store.value, 3);
    await subscription.cancel();
  });

  test('a late listener starts from the latest value', () async {
    final store = FakeStore('a')..value = 'b';
    expect(await store.watch().first, 'b');
  });
}
