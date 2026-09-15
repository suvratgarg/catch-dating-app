import 'package:catch_dating_app/onboarding/presentation/pages/gender_interest_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/instagram_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/phone_preview.dart';
import 'scope.dart';

@widgetbook.UseCase(
  name: 'Identity form',
  type: NameDobPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget nameDobPageStates(BuildContext context) {
  return const WidgetbookWrapCatalogFrame(
    title: 'NameDobPage',
    children: [
      WidgetbookPhoneStateCard(
        label: 'default',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(child: NameDobPage()),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'prefilled draft',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.nameDobPrefilled,
            child: NameDobPage(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'text scale 2',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookPhoneMediaOverride(
            textScale: 2,
            child: WidgetbookOnboardingScope(
              mode: WidgetbookOnboardingMode.nameDobPrefilled,
              child: NameDobPage(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Gender and interest form',
  type: GenderInterestPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget genderInterestPageStates(BuildContext context) {
  return const WidgetbookWrapCatalogFrame(
    title: 'GenderInterestPage',
    children: [
      WidgetbookPhoneStateCard(
        label: 'default',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(child: GenderInterestPage()),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'selected values',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.genderInterestSelected,
            child: GenderInterestPage(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'save pending',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.saveProfilePending,
            child: GenderInterestPage(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'save error',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.saveProfileError,
            child: GenderInterestPage(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'reduced motion',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookPhoneMediaOverride(
            disableAnimations: true,
            child: WidgetbookOnboardingScope(
              mode: WidgetbookOnboardingMode.genderInterest,
              child: GenderInterestPage(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Instagram form',
  type: InstagramPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget instagramPageStates(BuildContext context) {
  return const WidgetbookWrapCatalogFrame(
    title: 'InstagramPage',
    children: [
      WidgetbookPhoneStateCard(
        label: 'default',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(child: InstagramPage()),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'filled handle',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.instagramFilled,
            child: InstagramPage(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'skipped handle',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.instagramSkipped,
            child: InstagramPage(),
          ),
        ),
      ),
    ],
  );
}
