import 'package:catch_dating_app/swipes/shared/profile_surface/profile_body.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_view.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Raw profile view states',
  type: ProfileBody,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchProfileViewStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProfileBody',
    contractId: 'screen.catches.profile.raw',
    children: [
      WidgetbookPageStateCard(
        label: 'read only',
        child: WidgetbookCatchesDeviceFrame(
          child: ProfileBody(data: widgetbookCatchesProfileView(context)),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'reactable',
        child: WidgetbookCatchesDeviceFrame(
          child: ProfileBody(
            data: widgetbookCatchesProfileView(context),
            onReact: widgetbookCatchesNoopReaction,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hero states',
  type: ProfileHeader,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileHeroWidgetStates(BuildContext context) {
  final data = widgetbookCatchesProfileView(context);
  return WidgetbookPageCatalogFrame(
    title: 'ProfileHeader',
    contractId: 'screen.catches.profile.hero',
    children: [
      WidgetbookPageStateCard(
        label: 'read only',
        child: WidgetbookCatchesSectionFrame(
          height: CatchLayout.maxContentWithDockHeight,
          child: ProfileHeader(data: data),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'reactable',
        child: WidgetbookCatchesSectionFrame(
          height: CatchLayout.maxContentWithDockHeight,
          child: ProfileHeader(
            data: data,
            onReact: widgetbookCatchesNoopReaction,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Person polaroid states',
  type: CatchPolaroid,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchPersonPolaroidStates(BuildContext context) {
  final data = widgetbookCatchesProfileView(context);
  return WidgetbookPageCatalogFrame(
    title: 'CatchPolaroid',
    contractId: 'card.person.polaroid',
    children: [
      WidgetbookPageStateCard(
        label: 'profile identity',
        child: CatchPolaroid(
          media: ProfilePhoto(image: data.heroPhoto),
          kicker: data.kicker,
          name: '${data.name}, ${data.age}',
          meta: data.metaLine,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo states',
  type: ProfilePhoto,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profilePhotoStates(BuildContext context) {
  final data = widgetbookCatchesProfileView(context);
  return WidgetbookPageCatalogFrame(
    title: 'ProfilePhoto',
    contractId: 'screen.catches.profile.photo',
    children: [
      WidgetbookPageStateCard(
        label: 'graded photo',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.defaultPhonePreviewHeight,
          child: ProfilePhoto(image: data.heroPhoto),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'activity fallback',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.defaultPhonePreviewHeight,
          child: ProfilePhoto(image: null, activity: data.kickerActivity),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo block states',
  type: ProfilePhotoSection,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profilePhotoBlockStates(BuildContext context) {
  final section = widgetbookCatchesProfileSection<ProfilePhotoSectionData>(
    context,
  );
  return WidgetbookPageCatalogFrame(
    title: 'ProfilePhotoSection',
    contractId: 'screen.catches.profile.photo_block',
    children: [
      WidgetbookPageStateCard(
        label: 'caption',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.defaultPhonePreviewHeight,
          child: ProfilePhotoSection(section: section),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'reactable',
        child: WidgetbookCatchesSectionFrame(
          height: WidgetbookPreviewLayout.defaultPhonePreviewHeight,
          child: ProfilePhotoSection(
            section: section,
            onReact: widgetbookCatchesNoopReaction,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo caption states',
  type: ProfileCaptionText,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget photoCaptionStates(BuildContext context) {
  return const WidgetbookPageCatalogFrame(
    title: 'ProfileCaptionText',
    contractId: 'screen.catches.profile.photo_caption',
    children: [
      WidgetbookPageStateCard(
        label: 'overlay copy',
        child: WidgetbookCatchesDeckChromeFrame(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: CatchInsets.content,
              child: ProfileCaptionText(
                text: 'Post-run coffee is non-negotiable.',
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
