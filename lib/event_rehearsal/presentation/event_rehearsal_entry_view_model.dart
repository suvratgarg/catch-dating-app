import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_configuration.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_rehearsal_entry_view_model.g.dart';

final class EventRehearsalEntryData {
  const EventRehearsalEntryData({
    required this.organizerDefaults,
    required this.events,
    required this.initialConfiguration,
  });

  final ClubHostDefaults organizerDefaults;
  final List<Event> events;
  final EventRehearsalConfiguration initialConfiguration;
}

/// One bounded upcoming-event window; failed lookups remain errors rather than
/// being presented as an organizer with no event or no configured defaults.
@riverpod
Future<EventRehearsalEntryData> eventRehearsalEntry(
  Ref ref,
  String organizerId,
  String? sourceEventId,
) async {
  final clubs = ref.watch(clubsRepositoryProvider);
  final eventsRepository = ref.watch(eventRepositoryProvider);
  final plans = ref.watch(eventSuccessRepositoryProvider);
  final clubFuture = clubs.fetchClub(organizerId);
  final upcomingFuture = eventsRepository.fetchUpcomingEventsForClubs([
    organizerId,
  ]);
  final sourceFuture = sourceEventId == null
      ? Future<Event?>.value()
      : eventsRepository.fetchEvent(sourceEventId);
  final (club, events, explicitSource) = await (
    clubFuture,
    upcomingFuture,
    sourceFuture,
  ).wait;
  if (club == null) {
    throw const DocumentNotFoundException('rehearsal organizer');
  }
  if (sourceEventId != null && explicitSource == null) {
    throw const DocumentNotFoundException('rehearsal source event');
  }
  final source = explicitSource ?? events.firstOrNull;
  if (source != null && source.organizerId != organizerId) {
    throw const PermissionException(
      'This event does not belong to the rehearsal organizer.',
    );
  }
  final plan = source == null ? null : await plans.fetchPlan(source.id);
  return EventRehearsalEntryData(
    organizerDefaults: club.hostDefaults,
    events: List.unmodifiable([
      if (explicitSource != null &&
          !events.any((event) => event.id == explicitSource.id))
        explicitSource,
      ...events,
    ]),
    initialConfiguration: EventRehearsalConfiguration.defaults(
      organizerDefaults: club.hostDefaults,
      event: source,
      plan: plan,
    ),
  );
}
