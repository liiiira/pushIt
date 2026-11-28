import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/home/presentation/cubit/home_cubit.dart';
import 'package:pushit/features/home/presentation/views/home_view.dart';

/// The Home tab (B1, B2).
class HomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => HomeCubit(
      posts: context.read<PostsRepository>(),
      accounts: context.read<AccountsRepository>(),
      subscription: context.read<SubscriptionRepository>(),
      auth: context.read<AuthRepository>(),
      clock: context.read<Clock>(),
    )..started(),
    child: const HomeView(),
  );
}
