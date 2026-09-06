import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_ui/catch_ui.dart';

/// Resolves optional-field copy at the app's localization boundary.
CatchFormFieldLabelCopy catchFormFieldLabelCopy(AppLocalizations l10n) =>
    CatchFormFieldLabelCopy(
      optionalLabel: l10n.coreCatchFormFieldLabelTextOptional,
      optionalSuffix: l10n.coreCatchFieldTextOptionalSuffix,
      optionalSemantics: (label) =>
          l10n.coreCatchFormFieldLabelLabelLabelOptional(label: label),
    );

/// Resolves recovery copy without coupling shared error widgets to the app.
CatchFrameworkErrorCopy catchFrameworkErrorCopy(AppLocalizations l10n) =>
    CatchFrameworkErrorCopy(
      title: l10n.coreCatchFrameworkErrorViewTextSomethingWentWrong,
      message: l10n.coreCatchFrameworkErrorViewTextThisScreenHitA,
      debugDetailsLabel: l10n.coreCatchFrameworkErrorViewTextDeveloperDetails,
    );
