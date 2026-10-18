import 'package:catch_dating_app/onboarding/presentation/pages/onboarding_running_prefs_step.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/phone_preview.dart';
import 'scope.dart';

@widgetbook.UseCase(
  name: 'Run preferences form',
  type: OnboardingRunningPrefsBody,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget runningPrefsPageStates(BuildContext context) {
  return const WidgetbookWrapCatalogFrame(
    title: 'OnboardingRunningPrefsBody',
    children: [
      WidgetbookPhoneStateCard(
        label: 'onboarding completion',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(child: OnboardingRunningPrefsBody()),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'booking resume',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            child: OnboardingRunningPrefsBody(runPreferencesOnly: true),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'complete pending',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.completePending,
            child: OnboardingRunningPrefsBody(runPreferencesOnly: true),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'complete error',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.completeError,
            child: OnboardingRunningPrefsBody(runPreferencesOnly: true),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'text scale 2',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookPhoneMediaOverride(
            textScale: 2,
            child: WidgetbookOnboardingScope(
              child: OnboardingRunningPrefsBody(runPreferencesOnly: true),
            ),
          ),
        ),
      ),
    ],
  );
}
