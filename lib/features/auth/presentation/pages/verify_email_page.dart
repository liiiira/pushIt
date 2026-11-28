import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/presentation/cubit/verify_email_cubit.dart';
import 'package:pushit/features/auth/presentation/views/verify_email_view.dart';

/// A7.
class VerifyEmailPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        VerifyEmailCubit(auth: context.read<AuthRepository>())..started(),
    child: const VerifyEmailView(),
  );
}
