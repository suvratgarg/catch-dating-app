part of 'event_detail_screen.dart';

class _EventDetailBottomNavigationBar extends StatelessWidget {
  const _EventDetailBottomNavigationBar({
    required this.event,
    required this.userProfile,
    required this.clubId,
    required this.isAuthenticated,
    this.isSaved = false,
    this.isHosted = false,
    this.isClubMember = false,
    required this.participation,
    required this.organizerCapabilities,
    required this.inviteCode,
    required this.inviteLinkId,
    required this.now,
    required this.darkSurface,
    required this.completeProfileLabel,
    required this.onGuestBook,
    required this.onCompleteProfile,
  });

  final Event event;
  final UserProfile? userProfile;
  final String clubId;
  final bool isAuthenticated;
  final bool isSaved;
  final bool isHosted;
  final bool isClubMember;
  final EventParticipation? participation;
  final OrganizerSupplyCapabilities organizerCapabilities;
  final String? inviteCode;
  final String? inviteLinkId;
  final DateTime now;
  final bool darkSurface;
  final String completeProfileLabel;
  final VoidCallback onGuestBook;
  final VoidCallback onCompleteProfile;

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) {
      return GuestBookCta(onPressed: onGuestBook, darkSurface: darkSurface);
    }

    if (!eventDetailHasBookingReadyProfile(userProfile, now: now)) {
      return EventBookingDock(
        label: completeProfileLabel,
        onPressed: onCompleteProfile,
      );
    }

    return EventDetailCta(
      event: event,
      userProfile: userProfile!,
      clubId: clubId,
      participation: participation,
      organizerCapabilities: organizerCapabilities,
      isSaved: isSaved,
      isHosted: isHosted,
      isClubMember: isClubMember,
      inviteCode: inviteCode,
      inviteLinkId: inviteLinkId,
      now: now,
      darkSurface: darkSurface,
    );
  }
}
