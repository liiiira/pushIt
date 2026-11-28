import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/post_detail_cubit.dart';
import 'package:pushit/features/library/presentation/views/post_detail_view.dart';

/// One post (F3, F4).
class PostDetailPage extends StatelessWidget {
  const new({required this.postId, super.key});

  final String postId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => PostDetailCubit(
      postId: postId,
      posts: context.read<PostsRepository>(),
      accounts: context.read<AccountsRepository>(),
      subscription: context.read<SubscriptionRepository>(),
    )..started(),
    child: const PostDetailView(),
  );
}
