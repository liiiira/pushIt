import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

/// Pass to `pumpApp(router: …)` to verify navigation calls.
class MockGoRouter extends Mock implements GoRouter;
