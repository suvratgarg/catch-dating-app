import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_body.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
    this.inviteCode,
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;
  final String? inviteCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmAsync = ref.watch(eventDetailViewModelProvider(eventId));
    final vm = vmAsync.asData?.value;

    if (vm != null) {
      return _buildBody(vm);
    }

    if (vmAsync.isLoading && _initialEventMatchesRoute) {
      return _buildInitialEventBody(ref, initialEvent!);
    }

    if (vmAsync.isLoading) {
      return const Scaffold(body: CatchLoadingIndicator());
    }

    if (vmAsync.hasError) {
      return CatchErrorScaffold.fromError(
        vmAsync.error!,
        context: AppErrorContext.event,
        onRetry: () => ref.invalidate(eventDetailViewModelProvider(eventId)),
      );
    }

    return const CatchErrorScaffold(
      title: 'Event not found',
      message: 'This event is no longer available.',
    );
  }

  bool get _initialEventMatchesRoute =>
      initialEvent != null &&
      initialEvent!.id == eventId &&
      initialEvent!.clubId == clubId;

  Widget _buildBody(EventDetailViewModel vm) {
    return EventDetailBody(
      event: vm.event,
      userProfile: vm.userProfile,
      clubId: clubId,
      reviews: vm.reviews,
      isAuthenticated: vm.isAuthenticated,
      isHost: vm.isHost,
      isSaved: vm.isSaved,
      participation: vm.participation,
      inviteCode: inviteCode,
    );
  }

  Widget _buildInitialEventBody(WidgetRef ref, Event event) {
    final currentUid = ref.watch(uidProvider).asData?.value;
    final isAuthenticated = currentUid != null;
    final userProfile = isAuthenticated
        ? ref.watch(watchUserProfileProvider).asData?.value
        : null;
    final reviews = isAuthenticated
        ? ref.watch(watchReviewsForEventProvider(event.id)).asData?.value ??
              const <Review>[]
        : const <Review>[];
    final club = isAuthenticated
        ? ref.watch(fetchClubProvider(event.clubId)).asData?.value
        : null;
    final savedEvent = currentUid == null
        ? null
        : ref
              .watch(watchSavedEventProvider(currentUid, event.id))
              .asData
              ?.value;
    final participation = currentUid == null
        ? null
        : ref
              .watch(watchEventParticipationProvider(event.id, currentUid))
              .asData
              ?.value;

    return EventDetailBody(
      event: event,
      userProfile: userProfile,
      clubId: clubId,
      reviews: reviews,
      isAuthenticated: isAuthenticated,
      isHost: currentUid != null && club?.isHostedBy(currentUid) == true,
      isSaved: savedEvent != null,
      participation: participation,
      inviteCode: inviteCode,
    );
  }
}
