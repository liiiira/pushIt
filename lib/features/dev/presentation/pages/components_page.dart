import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/app_checkbox.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/app_radio.dart';
import 'package:pushit/core/design_system/widgets/app_segmented_control.dart';
import 'package:pushit/core/design_system/widgets/app_switch.dart';
import 'package:pushit/core/design_system/widgets/app_text_field.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// The design-system gallery (`/dev/components`, debug builds only): every
/// shared widget, once in light and once in dark.
///
/// No state and no cubit, so the page holds its own layout.
class ComponentsPage extends StatelessWidget {
  const new({super.key});

  static const ValueKey<String> lightSampleKey = ValueKey('components-light');
  static const ValueKey<String> darkSampleKey = ValueKey('components-dark');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppTopBar(title: l10n.devComponentsTitle),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ThemeSample(
              key: lightSampleKey,
              theme: AppTheme.light(),
              name: l10n.devComponentsLight,
            ),
            _ThemeSample(
              key: darkSampleKey,
              theme: AppTheme.dark(),
              name: l10n.devComponentsDark,
            ),
          ],
        ),
      ),
    );
  }
}

/// Every section, under [theme], on that theme's background.
class _ThemeSample extends StatelessWidget {
  const new({required this.theme, required this.name, super.key});

  final ThemeData theme;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => ColoredBox(
          color: context.colors.bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Margin(
                  child: Text(
                    name,
                    style: context.textStyles.h1.copyWith(
                      color: context.colors.text,
                    ),
                  ),
                ),
                const _ButtonsSection(),
                const _TopBarsSection(),
                const _CardsSection(),
                const _InputsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Margin extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
    child: child,
  );
}

/// A section title, then [children] stacked with a small gap.
class _Section extends StatelessWidget {
  const new({required this.title, required this.children, this.margin = true});

  final String title;
  final List<Widget> children;

  /// Whether the children get the screen margin.
  final bool margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Margin(
            child: Text(
              title,
              style: context.textStyles.small.copyWith(
                color: context.colors.sub,
              ),
            ),
          ),
          for (final child in children)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: margin ? _Margin(child: child) : child,
            ),
        ],
      ),
    );
  }
}

class _ButtonsSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = l10n.devComponentsSampleLabel;
    void noop() {}
    return _Section(
      title: l10n.devComponentsButtons,
      children: [
        PrimaryButton(label: label, onPressed: noop),
        PrimaryButton(label: label, onPressed: null),
        SecondaryButton(label: label, onPressed: noop),
        TextActionButton(label: label, onPressed: noop),
        Wrap(
          spacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PrimaryButton(
              label: label,
              size: AppButtonSize.small,
              onPressed: noop,
            ),
            SecondaryButton(
              label: label,
              size: AppButtonSize.small,
              onPressed: noop,
            ),
            TextActionButton(
              label: label,
              size: AppButtonSize.small,
              isUnderlined: true,
              onPressed: noop,
            ),
          ],
        ),
      ],
    );
  }
}

class _TopBarsSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Section(
      title: l10n.devComponentsTopBars,
      margin: false,
      children: [
        AppTopBar(
          title: l10n.devComponentsSampleTitle,
          onLeadingPressed: () {},
          trailing: TextActionButton(
            label: l10n.devComponentsSampleLabel,
            size: AppButtonSize.small,
            onPressed: () {},
          ),
        ),
        AppTopBar(
          title: l10n.devComponentsSampleTitle,
          leading: AppTopBarLeading.close,
          onLeadingPressed: () {},
        ),
      ],
    );
  }
}

class _CardsSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Section(
      title: l10n.devComponentsCards,
      children: [
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            children: [
              AppListRow(
                leading: const Icon(LucideIcons.bell),
                title: l10n.devComponentsSampleTitle,
                subtitle: l10n.devComponentsSampleSubtitle,
                hasChevron: true,
                onTap: () {},
              ),
              AppListRow(
                title: l10n.devComponentsSampleTitle,
                value: l10n.devComponentsSampleValue,
                isTitleMuted: true,
              ),
              AppListRow(
                title: l10n.devComponentsSampleTitle,
                subtitle: l10n.devComponentsSampleSubtitle,
                trailing: PrimaryButton(
                  label: l10n.devComponentsSampleLabel,
                  size: AppButtonSize.small,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
        AppCard(
          onTap: () {},
          child: Text(
            l10n.devComponentsSampleSubtitle,
            style: context.textStyles.body.copyWith(color: context.colors.text),
          ),
        ),
      ],
    );
  }
}

/// Fixed values with no-op handlers: the gallery shows each state side by
/// side instead of holding any.
class _InputsSection extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = l10n.devComponentsSampleLabel;
    void ignore(Object? _) {}
    return _Section(
      title: l10n.devComponentsInputs,
      children: [
        Row(
          children: [
            AppSwitch(value: true, onChanged: ignore),
            const SizedBox(width: AppSpacing.sm),
            AppSwitch(value: false, onChanged: ignore),
            const SizedBox(width: AppSpacing.sm),
            AppCheckbox(value: true, onChanged: ignore),
            AppCheckbox(value: false, onChanged: ignore),
          ],
        ),
        AppCheckbox(value: true, label: label, onChanged: ignore),
        for (final value in [0, 1])
          AppRadio<int>(
            value: value,
            groupValue: 0,
            label: label,
            onChanged: ignore,
          ),
        AppSegmentedControl<int>(
          segments: [
            for (final value in [0, 1, 2])
              AppSegment(value: value, label: label),
          ],
          selected: 0,
          onChanged: ignore,
        ),
        AppTextField(
          label: label,
          hint: l10n.devComponentsSampleHint,
          onChanged: ignore,
        ),
        AppTextField(
          label: label,
          initialValue: l10n.devComponentsSampleValue,
          errorText: l10n.devComponentsSampleError,
          onChanged: ignore,
        ),
        AppTextField(
          label: label,
          hint: l10n.devComponentsSampleHint,
          isMultiline: true,
          onChanged: ignore,
        ),
      ],
    );
  }
}
