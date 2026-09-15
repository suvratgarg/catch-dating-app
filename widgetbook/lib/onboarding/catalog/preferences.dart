import 'package:catch_dating_app/onboarding/presentation/pages/running_prefs_page.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/phone_preview.dart';
import 'scope.dart';

@widgetbook.UseCase(
  name: 'Run preferences form',
  type: RunningPrefsPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget runningPrefsPageStates(BuildContext context) {
  return const WidgetbookWrapCatalogFrame(
    title: 'RunningPrefsPage',
    children: [
      WidgetbookPhoneStateCard(
        label: 'onboarding completion',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(child: RunningPrefsPage()),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'booking resume',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            child: RunningPrefsPage(runPreferencesOnly: true),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'complete pending',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.completePending,
            child: RunningPrefsPage(runPreferencesOnly: true),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'complete error',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.completeError,
            child: RunningPrefsPage(runPreferencesOnly: true),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'text scale 2',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookPhoneMediaOverride(
            textScale: 2,
            child: WidgetbookOnboardingScope(
              child: RunningPrefsPage(runPreferencesOnly: true),
            ),
          ),
        ),
      ),
    ],
  );
}
