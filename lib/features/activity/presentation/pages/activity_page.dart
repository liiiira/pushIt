import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/activity/presentation/cubit/activity_cubit.dart';
import 'package:pushit/features/activity/presentation/views/activity_view.dart';

/// B3.
class ActivityPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => ActivityCubit(
      activity: context.read<ActivityRepository>(),
      posts: context.read<PostsRepository>(),
      clock: context.read<Clock>(),
    )..started(),
    child: const ActivityView(),
  );
}
