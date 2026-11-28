import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/app.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/app_router.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/preferences/app_preferences.dart';
import 'package:pushit/data/dependencies.dart';
import 'package:pushit/data/fake/scenario.dart';

/// The fake-data scenario: `--dart-define=SCENARIO=<name>`, one of
/// populated (default), firstUse, freeLimit, offline, error or slow.
/// An unknown name falls back to populated.
const scenarioName = String.fromEnvironment(
  'SCENARIO',
  defaultValue: 'populated',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedAppPreferences.load();
  final dependencies = Dependencies.fake(
    scenario: Scenario.fromName(scenarioName),
    clock: const SystemClock(),
  );
  // Phase 0: a fresh, signed-out user. Phase 2 feeds this from
  // AppPreferences and AuthRepository.
  final access = ValueNotifier(
    const AppAccess(isOnboarded: false, isSignedIn: false),
  );
  runApp(
    PushItApp(
      dependencies: dependencies,
      preferences: preferences,
      router: buildAppRouter(access: access),
    ),
  );
}
