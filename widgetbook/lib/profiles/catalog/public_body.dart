import 'package:catch_dating_app/public_profile/presentation/public_profile_screen.dart';
import 'package:catch_dating_app/public_profile/presentation/public_profile_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Route body states',
  type: PublicProfileScreenBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget publicProfileScreenBodyStates(BuildContext context) {
  return WidgetbookProfileProfileCatalog(
    title: 'PublicProfileScreenBody',
    contractId: 'screen.profile.public.route_body',
    children: [
      WidgetbookProfileStateCard(
        label: 'cold loading',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profilePhonePreviewHeight,
          child: PublicProfileScreenBody(
            state: PublicProfileScreenState(
              uid: widgetbookProfileTargetProfile.uid,
              status: PublicProfileRouteStatus.loading,
              mutationMode: PublicProfileMutationMode.idle,
              sharedRunTitle: null,
            ),
          ),
        ),
      ),
      WidgetbookProfileStateCard(
        label: 'load error',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profileSheetPreviewHeight,
          child: PublicProfileScreenBody(
            state: PublicProfileScreenState(
              uid: widgetbookProfileTargetProfile.uid,
              status: PublicProfileRouteStatus.error,
              error: StateError('Public profile failed'),
              retryIntent: PublicProfileRetryIntent.reloadProfile,
              mutationMode: PublicProfileMutationMode.idle,
              sharedRunTitle: null,
            ),
            onRetry: () {},
          ),
        ),
      ),
      WidgetbookProfileStateCard(
        label: 'profile unavailable',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profileSheetPreviewHeight,
          child: PublicProfileScreenBody(
            state: PublicProfileScreenState(
              uid: widgetbookProfileTargetProfile.uid,
              status: PublicProfileRouteStatus.unavailable,
              mutationMode: PublicProfileMutationMode.idle,
              sharedRunTitle: null,
            ),
          ),
        ),
      ),
      WidgetbookProfileStateCard(
        label: 'loaded with viewer context',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profilePhonePreviewHeight,
          child: PublicProfileScreenBody(
            state: PublicProfileScreenState(
              uid: widgetbookProfileTargetProfile.uid,
              status: PublicProfileRouteStatus.ready,
              profile: widgetbookProfileTargetProfile,
              viewerProfile: widgetbookProfileViewer,
              mutationMode: PublicProfileMutationMode.idle,
              sharedRunTitle: 'Morning miles',
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Body states',
  type: PublicProfileBody,
  path: '[P1 product surfaces]/Profiles',
)
Widget publicProfileBodyStates(BuildContext context) {
  return WidgetbookProfileProfileCatalog(
    title: 'PublicProfileBody',
    contractId: 'component.profile.public_body',
    children: [
      WidgetbookProfileStateCard(
        label: 'loaded public profile',
        child: WidgetbookProfileDeviceFrame(
          child: PublicProfileBody(
            profile: widgetbookProfileTargetProfile,
            viewerProfile: widgetbookProfileViewer,
            sharedRunTitle: 'Morning miles',
            submitting: false,
          ),
        ),
      ),
      WidgetbookProfileStateCard(
        label: 'submitting overlay',
        child: WidgetbookProfileDeviceFrame(
          child: PublicProfileBody(
            profile: widgetbookProfileTargetProfile,
            viewerProfile: widgetbookProfileViewer,
            submitting: true,
          ),
        ),
      ),
    ],
  );
}
