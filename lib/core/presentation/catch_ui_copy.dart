import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_ui/catch_ui.dart';

/// Keeps validation messages and their numeric grammar in the app catalog.
CatchFormValidationCopy catchFormValidationCopy(
  AppLocalizations l10n,
) => CatchFormValidationCopy(
  requiredMessage: (label) =>
      l10n.coreCatchFormValidationRequired(field: label),
  minLengthMessage: (label, minLength) =>
      l10n.coreCatchFormValidationMinLength(field: label, minLength: minLength),
  maxLengthMessage: (label, maxLength) =>
      l10n.coreCatchFormValidationMaxLength(field: label, maxLength: maxLength),
  patternMessage: (label) => l10n.coreCatchFormValidationPattern(field: label),
);

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

/// Keeps visibility labels and badge modes paired at the localization boundary.
CatchPrivacyBadgeCopy catchPrivacyBadgeCopy(AppLocalizations l10n) =>
    CatchPrivacyBadgeCopy(
      privateToYouLabel: l10n.coreCatchPrivacyBadgeLabelPrivateToYou,
      hostCanSeeLabel: l10n.coreCatchPrivacyBadgeLabelHostCanSee,
      catchPrivateLabel: l10n.coreCatchPrivacyBadgeLabelCatchPrivate,
    );

/// Formats avatar overflow counts at the app's localization boundary.
String Function(int) catchAvatarCountLabelBuilder(AppLocalizations l10n) =>
    (count) => l10n.coreCatchPersonAvatarTextCount(count: count);

/// Resolves person-row text and count semantics without app imports in the UI package.
CatchPersonRowCopy catchPersonRowCopy(AppLocalizations l10n) =>
    CatchPersonRowCopy(
      typingLabel: l10n.coreCatchPersonRowTextTyping,
      newMatchLabel: l10n.coreCatchPersonRowLabelNewMatch,
      unreadCountLabel: (count) => count == 1
          ? l10n.coreCatchPersonRowLabelUnreadChat
          : l10n.coreCatchPersonRowLabelLabelUnreadChats(
              label: catchCountLabel(count),
            ),
    );

/// Resolves the date picker's fixed toolbar and default-title copy.
CatchPickerCopy catchDatePickerCopy(AppLocalizations l10n) => CatchPickerCopy(
  title: l10n.coreCatchAdaptivePickerVisiblecopySelectDate,
  cancelLabel: l10n.coreCatchAdaptivePickerTextCancel,
  doneLabel: l10n.coreCatchAdaptivePickerTextDone,
);

/// Resolves the time picker's fixed toolbar and default-title copy.
CatchPickerCopy catchTimePickerCopy(AppLocalizations l10n) => CatchPickerCopy(
  title: l10n.coreCatchAdaptivePickerVisiblecopySelectTime,
  cancelLabel: l10n.coreCatchAdaptivePickerTextCancel,
  doneLabel: l10n.coreCatchAdaptivePickerTextDone,
);

/// Resolves confirmation defaults without importing the app catalog in shared UI.
CatchDialogCopy catchDialogCopy(AppLocalizations l10n) => CatchDialogCopy(
  cancelLabel: l10n.coreCatchAdaptiveDialogVisiblecopyCancel,
  confirmLabel: l10n.coreCatchAdaptiveDialogVisiblecopyConfirm,
);
