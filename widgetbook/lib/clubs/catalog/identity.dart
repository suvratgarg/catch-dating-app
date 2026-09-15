import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/page_preview.dart';
import 'fixtures.dart';

@widgetbook.UseCase(
  name: 'Member seal states',
  type: ClubMemberSeal,
  path: '[Club Discovery]/Atoms',
)
Widget clubMemberSealStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return WidgetbookScrollCatalogFrame(
    title: 'ClubMemberSeal',
    catalogId: 'atom.club.member_seal',
    children: [
      WidgetbookPageStateCard(
        label: 'default',
        child: ClubMemberSeal(
          label: clubMemberCountLabel(widgetbookClubClub),
          accent: t.primary,
        ),
      ),
      WidgetbookPageStateCard(
        label: 'compact',
        child: ClubMemberSeal(
          label: clubMemberCountLabel(widgetbookClubMinimalClub),
          accent: t.primary,
          compact: true,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tag wrap states',
  type: ClubTagWrap,
  path: '[Club Discovery]/Atoms',
)
Widget clubTagWrapStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubTagWrap',
    catalogId: 'atom.club.tag_wrap',
    children: [
      WidgetbookPageStateCard(
        label: 'brand tags',
        child: ClubTagWrap(tags: visibleClubTags(widgetbookClubClub, limit: 4)),
      ),
      const WidgetbookPageStateCard(
        label: 'neutral mixed case',
        child: ClubTagWrap(
          tags: ['coffee', 'first timers'],
          tone: CatchBadgeTone.neutral,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host identity states',
  type: ClubHostIdentityLine,
  path: '[Club Discovery]/Atoms',
)
Widget clubHostIdentityLineStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubHostIdentityLine',
    catalogId: 'atom.club.host_identity_line',
    children: [
      WidgetbookPageStateCard(
        label: 'with trailing',
        child: ClubHostIdentityLine(
          hostName: widgetbookClubClub.displayHostName,
          hostAvatarUrl: widgetbookClubClub.hostAvatarUrl,
          trailing: const ClubHostRoleBadge(role: ClubHostRole.owner),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'fallback avatar',
        child: ClubHostIdentityLine(
          hostName: widgetbookClubMinimalClub.displayHostName,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Role badge states',
  type: ClubHostRoleBadge,
  path: '[Club Discovery]/Atoms',
)
Widget clubHostRoleBadgeStates(BuildContext context) {
  return const WidgetbookScrollCatalogFrame(
    title: 'ClubHostRoleBadge',
    catalogId: 'atom.club.host_role_badge',
    children: [
      WidgetbookPageStateCard(
        label: 'owner',
        child: ClubHostRoleBadge(role: ClubHostRole.owner),
      ),
      WidgetbookPageStateCard(
        label: 'host',
        child: ClubHostRoleBadge(role: ClubHostRole.host),
      ),
    ],
  );
}
