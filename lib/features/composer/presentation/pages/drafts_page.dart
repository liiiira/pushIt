import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/drafts_cubit.dart';
import 'package:pushit/features/composer/presentation/views/drafts_view.dart';

/// D12: Drafts.
class DraftsPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        DraftsCubit(posts: context.read<PostsRepository>())..started(),
    child: const DraftsView(),
  );
}
