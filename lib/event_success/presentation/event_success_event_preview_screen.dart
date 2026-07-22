import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_event_preview_body_screen.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_event_preview_loading_screen.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catch_dating_app/l10n/l10n.dart';

export 'package:catch_dating_app/event_success/presentation/event_success_event_preview_body_screen.dart';
export 'package:catch_dating_app/event_success/presentation/event_success_event_preview_loading_screen.dart';

/// Dev/staging-only route that previews the future event-success layer against
/// today's event data. This route is read-only and intentionally does not create
/// event-success documents, check-in codes, crushes, prompts, or reports.
class EventSuccessEventPreviewRouteScreen extends ConsumerWidget {
  const EventSuccessEventPreviewRouteScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(watchEventProvider(eventId));
    final event = eventAsync.asData?.value ?? initialEvent;
    final clubAsync = ref.watch(fetchClubProvider(clubId));
    final rosterAsync = ref.watch(
      watchEventParticipationRosterProvider(eventId),
    );
    final userProfileAsync = ref.watch(watchUserProfileProvider);

    if (event == null && eventAsync.isLoading) {
      return const EventSuccessEventPreviewLoadingScreen();
    }

    if (event == null) {
      final error = eventAsync.error;
      if (error != null) {
        return CatchErrorScaffold.fromError(
          error,
          context: AppErrorContext.event,
          onRetry: () => ref.invalidate(watchEventProvider(eventId)),
        );
      }

      return CatchErrorScaffold(
        title: context
            .l10n
            .eventSuccessEventSuccessEventPreviewScreenTitleEventNotFound,
        message: context
            .l10n
            .eventSuccessEventSuccessEventPreviewScreenMessageThisEventIsNo,
        secondaryAction: const CatchErrorBackAction(),
      );
    }

    return EventSuccessEventPreviewScreen(
      event: event,
      club: clubAsync.asData?.value,
      roster: rosterAsync.asData?.value,
      userProfile: userProfileAsync.asData?.value,
    );
  }
}
