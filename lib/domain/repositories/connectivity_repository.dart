/// Whether the app is online (I1).
abstract interface class ConnectivityRepository {
  /// Emits the current state first, then every change.
  Stream<bool> watchOnline();
}
