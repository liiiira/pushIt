import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pushit/domain/domain.dart';

/// Whether the app is online, from [ConnectivityRepository]. The shell
/// shows the offline banner (I1) while this is false.
class ConnectivityCubit extends Cubit<bool> {
  new(ConnectivityRepository connectivity) : super(true) {
    _subscription = connectivity.watchOnline().listen(
      emit,
      // A failing watch says nothing about the connection: keep the state.
      onError: (Object _) {},
    );
  }

  // Assigned in the constructor body, once the stream is listened to.
  late final StreamSubscription<bool> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
