import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_preview_body.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab_body.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Preview tab states',
  type: ProfilePreviewBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget previewTabStates(BuildContext context) {
  return WidgetbookProfileProfileCatalog(
    title: 'ProfilePreviewBody',
    contractId: 'screen.profile.preview_tab',
    children: [
      WidgetbookProfileStateCard(
        label: 'public profile preview',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profilePhonePreviewHeight,
          child: ProfilePreviewBody(profile: widgetbookProfileOwnProfile),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Preview sliver body states',
  type: ProfilePreviewSliverBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profilePreviewSliverBodyStates(BuildContext context) {
  return WidgetbookProfileProfileCatalog(
    title: 'ProfilePreviewSliverBody',
    contractId: 'screen.profile.preview_tab.sliver_body',
    children: [
      WidgetbookProfileStateCard(
        label: 'public profile preview',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profilePhonePreviewHeight,
          child: CustomScrollView(
            slivers: [
              ProfilePreviewSliverBody(
                profile: widgetbookProfileOwnProfile,
                scrollController: ScrollController(),
                onForwardScroll: (_) => 0,
                onLeadingOverscroll: (_) {},
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Preview sliver skeleton',
  type: ProfilePreviewSkeletonSliverBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profilePreviewSkeletonSliverBodyStates(BuildContext context) {
  return WidgetbookProfileProfileCatalog(
    title: 'ProfilePreviewSkeletonSliverBody',
    contractId: 'screen.profile.preview_tab.sliver_loading',
    children: [
      WidgetbookProfileStateCard(
        label: 'profile loading',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profilePhonePreviewHeight,
          child: CustomScrollView(
            slivers: [
              ProfilePreviewSkeletonSliverBody(
                scrollController: ScrollController(),
                onForwardScroll: (_) => 0,
                onLeadingOverscroll: (_) {},
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Edit tab content states',
  type: ProfileTabBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileTabContentStates(BuildContext context) {
  return WidgetbookProfileProfileCatalog(
    title: 'ProfileTabBody',
    contractId: 'screen.profile.edit_tab.content',
    children: [
      WidgetbookProfileStateCard(
        label: 'list body builder',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profileExpandedPreviewHeight,
          child: ProfileTabBody(
            user: widgetbookProfileViewer,
            uploadState: widgetbookProfileIdlePhotoUploadState,
            builder: (context, children) => ListView(
              padding: CatchInsets.formEditBodyRelaxed,
              children: children,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Edit tab sliver body states',
  type: ProfileTabSliverBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileTabSliverBodyStates(BuildContext context) {
  return WidgetbookProfileProfileCatalog(
    title: 'ProfileTabSliverBody',
    contractId: 'screen.profile.edit_tab.sliver_body',
    children: [
      WidgetbookProfileStateCard(
        label: 'complete profile',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profileExpandedPreviewHeight,
          child: CustomScrollView(
            slivers: [
              CatchPageBody.slivers(
                mode: CatchPageBodyMode.standard,
                children: [
                  ProfileTabSliverBody(
                    user: widgetbookProfileViewer,
                    uploadState: widgetbookProfileIdlePhotoUploadState,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
