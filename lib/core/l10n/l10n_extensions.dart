import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Extension to easily access localized strings from BuildContext
///
/// Usage:
/// ```dart
/// Text(context.l10n.appName)
/// Text(context.l10n.ok)
/// ```
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
