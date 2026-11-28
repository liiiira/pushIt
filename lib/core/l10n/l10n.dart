import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;
import 'package:pushit/core/l10n/generated/app_localizations.dart';

export 'package:pushit/core/l10n/generated/app_localizations.dart';
export 'package:pushit/core/l10n/platform_names.dart';

extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The delegates for `MaterialApp`: ours, plus the Material, Cupertino and
/// widgets ones from `material_ui`.
///
/// Do not use `AppLocalizations.localizationsDelegates`: gen-l10n fills it
/// with the legacy `flutter_localizations` Material delegate, which
/// `material_ui` widgets do not read.
const appLocalizationsDelegates = <LocalizationsDelegate<Object?>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
