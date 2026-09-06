import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_index_row.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

Future<String?> showHostOrganizerSwitcherSheet({
  required BuildContext context,
  required List<Club> clubs,
  required String selectedOrganizerId,
}) {
  assert(clubs.length > 1, 'Organizer switcher requires multiple organizers.');
  return showCatchBottomSheet<String>(
    context: context,
    builder: (sheetContext) => HostOrganizerSwitcherSheet(
      clubs: clubs,
      selectedOrganizerId: selectedOrganizerId,
    ),
  );
}

class HostOrganizerAvatar extends StatelessWidget {
  const HostOrganizerAvatar({
    super.key,
    required this.club,
    required this.size,
    this.selected = false,
  });

  final Club club;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final rawLogoUrl = club.logoPhotoUrl?.trim();
    return CatchPersonAvatar(
      size: size,
      name: club.name,
      initials: CatchPersonAvatar.initialsOf(club.name),
      imageUrl: rawLogoUrl?.isNotEmpty == true ? rawLogoUrl : null,
      activityKind: club.hostDefaults.primaryActivityKind,
      borderWidth: selected ? CatchStroke.underline : CatchStroke.hairline,
      borderColor: selected ? t.ink : t.line2,
    );
  }
}

class HostOrganizerSwitcherSheet extends StatelessWidget {
  const HostOrganizerSwitcherSheet({
    super.key,
    required this.clubs,
    required this.selectedOrganizerId,
  });

  final List<Club> clubs;
  final String selectedOrganizerId;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchBottomSheetScaffold(
      key: const ValueKey<String>('host-organizer-switcher-sheet'),
      title: context.l10n.hostsHostTodayTooltipSwitchClub,
      child: CatchSurface(
        borderColor: t.line2,
        borderRadius: BorderRadius.circular(CatchRadius.md),
        clipBehavior: Clip.antiAlias,
        padding: CatchInsets.hostOrganizerSwitcherList,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final club in clubs)
              CatchIndexRow(
                key: ValueKey<String>(
                  'host-organizer-switcher-option-${club.id}',
                ),
                title: club.name,
                selected: club.id == selectedOrganizerId,
                leading: HostOrganizerAvatar(
                  club: club,
                  size: CatchLayout.organizerSwitcherAvatarExtent,
                  selected: club.id == selectedOrganizerId,
                ),
                trailing: SizedBox.square(
                  dimension: CatchLayout.menuRowCheckSize,
                  child: club.id == selectedOrganizerId
                      ? Icon(
                          CatchIcons.checkCircleFilled,
                          color: t.ink,
                          size: CatchLayout.menuRowCheckSize,
                        )
                      : null,
                ),
                onTap: () => Navigator.of(context).pop(club.id),
              ),
          ],
        ),
      ),
    );
  }
}
