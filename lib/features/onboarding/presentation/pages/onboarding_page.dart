import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/preferences/app_preferences.dart';
import 'package:pushit/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:pushit/features/onboarding/presentation/views/onboarding_view.dart';

/// A2–A4.
class OnboardingPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        OnboardingCubit(preferences: context.read<AppPreferences>()),
    child: const OnboardingView(),
  );
}
