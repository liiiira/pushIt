import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:pushit/features/auth/presentation/views/reset_password_view.dart';

/// A8.
class ResetPasswordPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        ResetPasswordCubit(auth: context.read<AuthRepository>()),
    child: const ResetPasswordView(),
  );
}
