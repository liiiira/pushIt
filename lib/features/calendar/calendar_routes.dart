import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/features/calendar/presentation/pages/calendar_page.dart';

/// E1–E3 (the Calendar tab). E4 is a sheet.
List<RouteBase> calendarRoutes() => [
  GoRoute(path: RoutePaths.calendar, builder: (_, _) => const CalendarPage()),
];
