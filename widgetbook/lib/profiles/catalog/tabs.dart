import 'package:catch_dating_app/user_profile/presentation/widgets/preview_tab.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Preview tab states',
  type: PreviewTab,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget previewTabStates(BuildContext context) {
  return WidgetbookProfileProfileCatalog(
    title: 'PreviewTab',
    contractId: 'screen.profile.preview_tab',
    children: [
      WidgetbookProfileStateCard(
        label: 'public profile preview',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profilePhonePreviewHeight,
          child: PreviewTab(profile: widgetbookProfileOwnProfile),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Edit tab states',
  type: ProfileTab,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileTabStates(BuildContext context) {
  return WidgetbookProfileProfileCatalog(
    title: 'ProfileTab',
    contractId: 'screen.profile.edit_tab',
    children: [
      WidgetbookProfileStateCard(
        label: 'complete profile',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profileExpandedPreviewHeight,
          child: ProfileTab(
            user: widgetbookProfileViewer,
            uploadState: widgetbookProfileIdlePhotoUploadState,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Edit tab content states',
  type: ProfileTabContent,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileTabContentStates(BuildContext context) {
  return WidgetbookProfileProfileCatalog(
    title: 'ProfileTabContent',
    contractId: 'screen.profile.edit_tab.content',
    children: [
      WidgetbookProfileStateCard(
        label: 'list body builder',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profileExpandedPreviewHeight,
          child: ProfileTabContent(
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
