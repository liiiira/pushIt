import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/delete_result_cubit.dart';
import 'package:pushit/features/library/presentation/views/delete_result_view.dart';

/// F7: Delete everywhere, the result per platform.
class DeleteResultPage extends StatelessWidget {
  const new({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => DeleteResultCubit(
      postId: postId,
      posts: context.read<PostsRepository>(),
    )..started(),
    child: DeleteResultView(postId: postId),
  );
}
