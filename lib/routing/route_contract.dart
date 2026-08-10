import 'package:catch_dating_app/core/app_config.dart';
import 'package:flutter/foundation.dart';

enum AppRouteAudience { shared, consumer, host }

enum Routes {
  loadingScreen('/loading', AppRouteAudience.shared),
  startScreen('/start', AppRouteAudience.shared),
  authScreen('/auth', AppRouteAudience.shared),
  onboardingScreen('/onboarding', AppRouteAudience.consumer),
  calendarScreen('/calendar', AppRouteAudience.consumer),
  calendarEventDetailScreen(
    '/calendar/organizers/:clubId/events/:eventId',
    AppRouteAudience.consumer,
  ),
  savedEventsScreen('/saved-events', AppRouteAudience.consumer),
  savedEventDetailScreen(
    '/saved-events/organizers/:clubId/events/:eventId',
    AppRouteAudience.consumer,
  ),
  filtersScreen('/filters', AppRouteAudience.consumer),
  dashboardEventDetailScreen(
    '/dashboard/organizers/:clubId/events/:eventId',
    AppRouteAudience.consumer,
  ),
  eventLocationMapScreen('/events/:eventId/location', AppRouteAudience.shared),
  dashboardScreen('/', AppRouteAudience.consumer),
  notificationsScreen('/notifications', AppRouteAudience.consumer),
  crossPathsInvitationScreen(
    '/cross-paths/invitations/:invitationId',
    AppRouteAudience.consumer,
  ),
  exploreScreen('/organizers', AppRouteAudience.consumer),
  exploreMapScreen('/organizers/map', AppRouteAudience.consumer),
  clubDetailScreen('/organizers/:clubId', AppRouteAudience.consumer),
  eventDetailScreen(
    '/organizers/:clubId/events/:eventId',
    AppRouteAudience.consumer,
  ),
  eventSuccessCompanionScreen(
    '/organizers/:clubId/events/:eventId/companion',
    AppRouteAudience.consumer,
  ),
  swipeHubScreen('/catches', AppRouteAudience.consumer),
  swipeEventScreen('/catches/:eventId', AppRouteAudience.consumer),
  eventRecapScreen('/catches/:eventId/recap', AppRouteAudience.consumer),
  matchesListScreen('/chats', AppRouteAudience.consumer),
  chatScreen('/chats/:matchId', AppRouteAudience.consumer),
  profileScreen('/you', AppRouteAudience.consumer),
  reviewsHistoryScreen('/you/reviews', AppRouteAudience.consumer),
  publicProfileScreen('/profiles/:uid', AppRouteAudience.consumer),
  settingsScreen('/settings', AppRouteAudience.consumer),
  launchAccessScreen('/settings/launch-access', AppRouteAudience.consumer),
  paymentHistoryScreen('/payment-history', AppRouteAudience.consumer),
  paymentConfirmationScreen('/payment-confirmation', AppRouteAudience.consumer),
  hostHomeScreen('/host', AppRouteAudience.host),
  hostEventsScreen('/host/events', AppRouteAudience.host),
  hostOrganizerScreen('/host/organizer', AppRouteAudience.host),
  hostClubsScreen('/host/organizers', AppRouteAudience.host),
  hostClubEventDefaultsScreen(
    '/host/organizers/event-defaults',
    AppRouteAudience.host,
  ),
  hostClubLiveGuideScreen('/host/organizers/live-guide', AppRouteAudience.host),
  hostClubTeamScreen('/host/organizers/team', AppRouteAudience.host),
  hostClubPaymentsScreen('/host/organizers/payments', AppRouteAudience.host),
  hostClubDetailScreen('/host/organizers/:clubId', AppRouteAudience.host),
  hostCreateClubScreen(
    '/host/organizers/create-organizer',
    AppRouteAudience.host,
  ),
  hostEditClubScreen('/host/organizers/:clubId/edit', AppRouteAudience.host),
  hostCreateEventScreen(
    '/host/organizers/:clubId/create-event',
    AppRouteAudience.host,
  ),
  hostAppEventDetailScreen(
    '/host/organizers/:clubId/events/:eventId',
    AppRouteAudience.host,
  ),
  hostAppEventManageScreen(
    '/host/organizers/:clubId/events/:eventId/manage',
    AppRouteAudience.host,
  ),
  hostAppEditEventScreen(
    '/host/organizers/:clubId/events/:eventId/edit',
    AppRouteAudience.host,
  ),
  hostAppAttendanceSheet(
    '/host/organizers/:clubId/events/:eventId/attendance',
    AppRouteAudience.host,
  ),
  hostAppEventSuccessScreen(
    '/host/organizers/:clubId/events/:eventId/success',
    AppRouteAudience.host,
  ),
  hostInboxScreen('/host/inbox', AppRouteAudience.host),
  hostChatScreen('/host/inbox/:matchId', AppRouteAudience.host);

  const Routes(this.path, this.audience);
  final String path;
  final AppRouteAudience audience;
}

@visibleForTesting
bool routeAvailableForAppRole(Routes route, AppRole role) {
  return switch (route.audience) {
    AppRouteAudience.shared => true,
    AppRouteAudience.consumer => !role.isHost,
    AppRouteAudience.host => role.isHost,
  };
}
