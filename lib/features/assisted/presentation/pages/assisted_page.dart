import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/assisted/presentation/cubit/assisted_cubit.dart';
import 'package:pushit/features/assisted/presentation/views/assisted_view.dart';

/// G2 or G3 for one post on one platform, from the route parameters.
class AssistedPage extends StatelessWidget {
  const new({
    required this.postId,
    required this.platformName,
    required this.mode,
    super.key,
  });

  final String postId;

  /// The `PlatformId` name in the route, e.g. `tiktok`.
  final String platformName;
  final AssistedMode mode;

  @override
  Widget build(BuildContext context) {
    final platform = PlatformId.values.asNameMap()[platformName];
    return BlocProvider(
      create: (context) => AssistedCubit(
        postId: postId,
        platform: platform,
        mode: mode,
        posts: context.read<PostsRepository>(),
      )..started(),
      child: AssistedView(platform: platform, mode: mode),
    );
  }
}
