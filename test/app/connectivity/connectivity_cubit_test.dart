import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/app/connectivity/connectivity_cubit.dart';
import 'package:pushit/domain/domain.dart';

class _MockConnectivity extends Mock implements ConnectivityRepository;

void main() {
  late _MockConnectivity connectivity;
  late StreamController<bool> online;

  setUp(() {
    connectivity = _MockConnectivity();
    online = StreamController<bool>();
    when(connectivity.watchOnline).thenAnswer((_) => online.stream);
  });

  tearDown(() => online.close());

  test('assumes online until told otherwise', () {
    expect(ConnectivityCubit(connectivity).state, isTrue);
  });

  blocTest<ConnectivityCubit, bool>(
    'follows the repository',
    build: () => ConnectivityCubit(connectivity),
    act: (_) async {
      online
        ..add(false)
        ..add(true);
    },
    expect: () => [false, true],
  );

  blocTest<ConnectivityCubit, bool>(
    'stays as it was when the stream fails',
    build: () => ConnectivityCubit(connectivity),
    act: (_) async {
      online
        ..add(false)
        ..addError(Exception('lost'));
    },
    expect: () => [false],
  );

  test('stops listening when closed', () async {
    final cubit = ConnectivityCubit(connectivity);

    await cubit.close();

    expect(online.hasListener, isFalse);
  });
}
