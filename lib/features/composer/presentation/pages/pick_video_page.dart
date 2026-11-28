import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/drafts_cubit.dart';
import 'package:pushit/features/composer/presentation/cubit/pick_video_cubit.dart';
import 'package:pushit/features/composer/presentation/views/pick_video_view.dart';

/// D1: Pick video.
class PickVideoPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) =>
            PickVideoCubit(media: context.read<MediaRepository>())..started(),
      ),
      BlocProvider(
        create: (context) =>
            DraftsCubit(posts: context.read<PostsRepository>())..started(),
      ),
    ],
    child: const PickVideoView(),
  );
}
