import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'scope.dart';

@widgetbook.UseCase(
  name: 'Membership trailing controller states',
  type: MembershipTrailingController,
  path: '[Club Discovery]/Atoms',
)
Widget membershipTrailingControllerStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'MembershipTrailingController',
    catalogId: 'atom.club.membership_trailing_controller',
    children: [
      WidgetbookPageStateCard(
        label: 'joinable controller',
        child: WidgetbookClubClubDirectoryPreviewScope(
          child: MembershipTrailingController(
            clubId: widgetbookClubClub.id,
            isJoined: false,
          ),
        ),
      ),
      const WidgetbookPageStateCard(
        label: 'joined controller',
        child: MembershipTrailingController(
          clubId: widgetbookClubClubId,
          isJoined: true,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Membership trailing states',
  type: MembershipTrailing,
  path: '[Club Discovery]/Atoms',
)
Widget membershipTrailingStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'MembershipTrailing',
    catalogId: 'atom.club.membership_trailing',
    children: [
      WidgetbookPageStateCard(
        label: 'join button',
        child: MembershipTrailing(
          isJoined: false,
          isPending: false,
          onJoinPressed: () {},
        ),
      ),
      const WidgetbookPageStateCard(
        label: 'pending',
        child: MembershipTrailing(
          isJoined: false,
          isPending: true,
          onJoinPressed: null,
        ),
      ),
      const WidgetbookPageStateCard(
        label: 'joined badge',
        child: MembershipTrailing(
          isJoined: true,
          isPending: false,
          onJoinPressed: null,
        ),
      ),
    ],
  );
}
