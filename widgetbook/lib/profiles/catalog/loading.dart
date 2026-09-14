import 'package:catch_dating_app/user_profile/presentation/widgets/profile_tab.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Edit tab skeleton states',
  type: ProfileTabSkeletonSliverBody,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileTabSkeletonSliverBodyStates(BuildContext context) {
  return const WidgetbookProfileProfileCatalog(
    title: 'ProfileTabSkeletonSliverBody',
    contractId: 'screen.profile.edit_tab.skeleton',
    children: [
      WidgetbookProfileStateCard(
        label: 'loading',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profilePhonePreviewHeight,
          child: CustomScrollView(
            slivers: [
              CatchPageBody.slivers(
                mode: CatchPageBodyMode.standard,
                children: [ProfileTabSkeletonSliverBody()],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo skeleton section states',
  type: ProfilePhotosSkeletonSection,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profilePhotosSkeletonSectionStates(BuildContext context) {
  return const WidgetbookProfileProfileCatalog(
    title: 'ProfilePhotosSkeletonSection',
    contractId: 'screen.profile.edit_tab.skeleton.photos',
    children: [
      WidgetbookProfileStateCard(
        label: 'loading photo grid',
        child: WidgetbookContentFrame(
          child: Padding(
            padding: CatchInsets.content,
            child: ProfilePhotosSkeletonSection(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Info skeleton section states',
  type: ProfileInfoSkeletonSection,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileInfoSkeletonSectionStates(BuildContext context) {
  return const WidgetbookProfileProfileCatalog(
    title: 'ProfileInfoSkeletonSection',
    contractId: 'screen.profile.edit_tab.skeleton.info_section',
    children: [
      WidgetbookProfileStateCard(
        label: 'single row',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profilePolaroidPreviewHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileInfoSkeletonSection(title: 'About you', rows: 1),
          ),
        ),
      ),
      WidgetbookProfileStateCard(
        label: 'divided rows',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.sliverPreviewHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileInfoSkeletonSection(title: 'Lifestyle', rows: 4),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Info skeleton tile states',
  type: ProfileInfoSkeletonTile,
  path: '[P1 product surfaces]/Profiles/Sections',
)
Widget profileInfoSkeletonTileStates(BuildContext context) {
  return const WidgetbookProfileProfileCatalog(
    title: 'ProfileInfoSkeletonTile',
    contractId: 'screen.profile.edit_tab.skeleton.info_tile',
    children: [
      WidgetbookProfileStateCard(
        label: 'row placeholder',
        child: WidgetbookProfileSectionFrame(
          height: WidgetbookPreviewLayout.profileCompactPreviewHeight,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileInfoSkeletonTile(),
          ),
        ),
      ),
    ],
  );
}
