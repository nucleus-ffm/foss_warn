import 'package:flutter/material.dart';
import 'package:foss_warn/l10n/app_localizations.dart';

extension Localizations on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this)!;
}
