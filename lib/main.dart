import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/app.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/app_router.dart';

/// The fake-data scenario: `--dart-define=SCENARIO=<name>`, one of
/// populated (default), firstUse, freeLimit, offline, error or slow.
///
/// Once Agent B's `Dependencies.fake` lands, `main` builds it from this.
const scenarioName = String.fromEnvironment(
  'SCENARIO',
  defaultValue: 'populated',
);

void main() {
  // Phase 0: a fresh, signed-out user. Phase 2 feeds this from
  // AppPreferences and AuthRepository.
  final access = ValueNotifier(
    const AppAccess(isOnboarded: false, isSignedIn: false),
  );
  runApp(PushItApp(router: buildAppRouter(access: access)));
}
