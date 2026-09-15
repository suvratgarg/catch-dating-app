import 'package:catch_dating_app/design_fixtures/profile_surface_fixtures.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/photos_page.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/phone_preview.dart';
import 'fixtures.dart';
import 'scope.dart';

final _profileReadyPhotos = ProfileSurfaceFixtures.viewer.copyWith(
  profileComplete: false,
  profilePhotos: ProfileSurfaceFixtures.viewer.profilePhotos
      .take(2)
      .toList(growable: false),
);

@widgetbook.UseCase(
  name: 'Photo grid states',
  type: PhotosPage,
  path: '[P1 product surfaces]/Onboarding/Pages',
)
Widget photosPageStates(BuildContext context) {
  return WidgetbookWrapCatalogFrame(
    title: 'PhotosPage',
    children: [
      WidgetbookPhoneStateCard(
        label: 'no photos disabled',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            profile: widgetbookOnboardingProfileNoPhotos,
            child: PhotosPage(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'one photo disabled',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            profile: widgetbookOnboardingProfileOnePhoto,
            child: PhotosPage(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'minimum photos',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            profile: _profileReadyPhotos,
            child: PhotosPage(),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'profile completion copy',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            profile: _profileReadyPhotos,
            child: PhotosPage(profileCompletionOnly: true),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'upload pending',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookOnboardingScope(
            profile: widgetbookOnboardingProfileOnePhoto,
            uploadState: widgetbookOnboardingSecondPhotoUploadingState,
            child: PhotosPage(profileCompletionOnly: true),
          ),
        ),
      ),
      WidgetbookPhoneStateCard(
        label: 'text scale 2',
        child: WidgetbookMaterialPhoneFrame(
          child: WidgetbookPhoneMediaOverride(
            textScale: 2,
            child: WidgetbookOnboardingScope(
              profile: widgetbookOnboardingProfileOnePhoto,
              child: PhotosPage(profileCompletionOnly: true),
            ),
          ),
        ),
      ),
    ],
  );
}
