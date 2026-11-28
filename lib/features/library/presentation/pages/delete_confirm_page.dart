import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/delete_confirm_cubit.dart';
import 'package:pushit/features/library/presentation/views/delete_confirm_view.dart';

/// F6: Delete everywhere, the confirmation.
class DeleteConfirmPage extends StatelessWidget {
  const new({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => DeleteConfirmCubit(
      postId: postId,
      posts: context.read<PostsRepository>(),
    )..started(),
    child: const DeleteConfirmView(),
  );
}
