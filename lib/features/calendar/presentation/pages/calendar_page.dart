import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:pushit/features/calendar/presentation/views/calendar_view.dart';

/// The Calendar tab (E1–E4).
class CalendarPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => CalendarCubit(
      posts: context.read<PostsRepository>(),
      clock: context.read<Clock>(),
    )..started(),
    child: const CalendarView(),
  );
}
