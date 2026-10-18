import 'package:catch_dating_app/onboarding/presentation/pages/onboarding_gender_interest_step.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/onboarding_instagram_step.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/onboarding_name_dob_step.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/phone_preview.dart';
import 'scope.dart';

@widgetbook.UseCase(
  name: 'Identity form',
  type: OnboardingNameDobBody,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget nameDobPageStates(BuildContext context) {
  return const WidgetbookWrapCatalogFrame(
    title: 'OnboardingNameDobBody',
    children: [
      WidgetbookPhoneStateCard(
        label: 'default',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(child: OnboardingNameDobBody()),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'prefilled draft',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.nameDobPrefilled,
            child: OnboardingNameDobBody(),
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
              child: OnboardingNameDobBody(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Gender and interest form',
  type: OnboardingGenderInterestBody,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget genderInterestPageStates(BuildContext context) {
  return const WidgetbookWrapCatalogFrame(
    title: 'OnboardingGenderInterestBody',
    children: [
      WidgetbookPhoneStateCard(
        label: 'default',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            child: OnboardingGenderInterestBody(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'selected values',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.genderInterestSelected,
            child: OnboardingGenderInterestBody(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'save pending',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.saveProfilePending,
            child: OnboardingGenderInterestBody(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'save error',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.saveProfileError,
            child: OnboardingGenderInterestBody(),
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
              child: OnboardingGenderInterestBody(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Instagram form',
  type: OnboardingInstagramBody,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget instagramPageStates(BuildContext context) {
  return const WidgetbookWrapCatalogFrame(
    title: 'OnboardingInstagramBody',
    children: [
      WidgetbookPhoneStateCard(
        label: 'default',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(child: OnboardingInstagramBody()),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'filled handle',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.instagramFilled,
            child: OnboardingInstagramBody(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'skipped handle',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            mode: WidgetbookOnboardingMode.instagramSkipped,
            child: OnboardingInstagramBody(),
          ),
        ),
      ),
    ],
  );
}
