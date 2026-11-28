import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';

/// Provides one [ComposerCubit] to every `/compose/*` screen.
class ComposerShell extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => ComposerCubit(
      media: context.read<MediaRepository>(),
      posts: context.read<PostsRepository>(),
      accounts: context.read<AccountsRepository>(),
      subscription: context.read<SubscriptionRepository>(),
    )..started(),
    child: child,
  );
}
