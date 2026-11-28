import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/core/preferences/app_preferences.dart';
import 'package:pushit/domain/domain.dart';

/// The live [AppAccess] the router guards with: the onboarded flag of
/// [AppPreferences] and the user of [AuthRepository].
///
/// It is unknown (the splash shows) until the auth state first arrives. An
/// auth error counts as signed out, so the app never hangs on the splash.
final class AppAccessNotifier extends ValueNotifier<AppAccess> {
  new({required AppPreferences preferences, required AuthRepository auth})
    : _isOnboarded = preferences.isOnboarded,
      super(AppAccess.unknown(isOnboarded: preferences.isOnboarded)) {
    _subscriptions.addAll([
      preferences.watchOnboarded().listen((isOnboarded) {
        _isOnboarded = isOnboarded;
        _publish();
      }),
      auth.watchUser().listen(
        _signedIn,
        onError: (Object _) => _signedIn(null),
      ),
    ]);
  }

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _isOnboarded;
  bool _isKnown = false;
  User? _user;

  void _signedIn(User? user) {
    _isKnown = true;
    _user = user;
    _publish();
  }

  void _publish() {
    final user = _user;
    value = _isKnown
        ? AppAccess(
            isOnboarded: _isOnboarded,
            isSignedIn: user != null,
            isEmailVerified: user == null || user.isEmailVerified,
          )
        : AppAccess.unknown(isOnboarded: _isOnboarded);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
