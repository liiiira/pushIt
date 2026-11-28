import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/edit_everywhere_cubit.dart';
import 'package:pushit/features/library/presentation/views/edit_everywhere_view.dart';

/// F5: Edit everywhere.
class EditEverywherePage extends StatelessWidget {
  const new({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => EditEverywhereCubit(
      postId: postId,
      posts: context.read<PostsRepository>(),
    )..started(),
    child: const EditEverywhereView(),
  );
}
