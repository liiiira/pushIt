import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/library_cubit.dart';
import 'package:pushit/features/library/presentation/views/library_view.dart';

/// The Library tab (F1–F2).
class LibraryPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        LibraryCubit(posts: context.read<PostsRepository>())..started(),
    child: const LibraryView(),
  );
}
