import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:pushit/features/auth/presentation/views/sign_in_view.dart';

/// A5.
class SignInPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => SignInCubit(auth: context.read<AuthRepository>()),
    child: const SignInView(),
  );
}
