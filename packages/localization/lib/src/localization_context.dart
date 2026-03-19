import 'package:flutter/widgets.dart';
import 'package:localization/src/generated/app_localizations.dart';

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
