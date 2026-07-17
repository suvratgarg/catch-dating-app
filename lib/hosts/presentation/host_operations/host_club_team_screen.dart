part of '../host_operations_screen.dart';

class HostClubTeamScreen extends StatelessWidget {
  const HostClubTeamScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context) {
    return HostClubSpokeResolver._(
      clubId: clubId,
      title: context.l10n.hostsHostClubEditTabLabelHostTeam,
      builder: (_, club, currentUid, isOwner) => HostTeamManagementSection(
        club: club,
        currentUid: currentUid,
        canManage: isOwner,
      ),
    );
  }
}
