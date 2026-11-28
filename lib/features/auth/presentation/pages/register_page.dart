import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/presentation/cubit/register_cubit.dart';
import 'package:pushit/features/auth/presentation/views/register_view.dart';

/// A6.
class RegisterPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => RegisterCubit(auth: context.read<AuthRepository>()),
    child: const RegisterView(),
  );
}
