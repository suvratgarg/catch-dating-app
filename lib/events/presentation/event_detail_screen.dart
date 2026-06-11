import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_body.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
    this.inviteCode,
    this.inviteLinkId,
    this.presentationMode = EventDetailPresentationMode.standard,
    this.heroTag,
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;
  final String? inviteCode;
  final String? inviteLinkId;
  final EventDetailPresentationMode presentationMode;
  final Object? heroTag;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  String? _recordedInviteLinkId;

  @override
  void initState() {
    super.initState();
    _recordInviteLinkOpen();
  }

  @override
  void didUpdateWidget(covariant EventDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventId != widget.eventId ||
        oldWidget.inviteLinkId != widget.inviteLinkId) {
      _recordInviteLinkOpen();
    }
  }

  void _recordInviteLinkOpen() {
    final inviteLinkId = widget.inviteLinkId?.trim();
    if (inviteLinkId == null || inviteLinkId.isEmpty) return;
    if (_recordedInviteLinkId == '${widget.eventId}:$inviteLinkId') return;
    _recordedInviteLinkId = '${widget.eventId}:$inviteLinkId';
    unawaited(_recordInviteLinkOpenBestEffort(inviteLinkId));
  }

  Future<void> _recordInviteLinkOpenBestEffort(String inviteLinkId) async {
    try {
      await ref
          .read(eventRepositoryProvider)
          .recordInviteLinkOpen(
            eventId: widget.eventId,
            inviteLinkId: inviteLinkId,
          );
    } catch (_) {
      // Invite attribution must never block event detail rendering.
    }
  }

  @override
  Widget build(BuildContext context) {
    final vmAsync = ref.watch(eventDetailViewModelProvider(widget.eventId));
    final vm = vmAsync.asData?.value;

    if (vm != null) {
      return _buildBody(vm);
    }

    if (vmAsync.isLoading && _initialEventMatchesRoute) {
      return _buildInitialEventBody(ref, widget.initialEvent!);
    }

    if (vmAsync.isLoading) {
      return const Scaffold(body: CatchLoadingIndicator());
    }

    if (vmAsync.hasError) {
      return CatchErrorScaffold.fromError(
        vmAsync.error!,
        context: AppErrorContext.event,
        onRetry: () =>
            ref.invalidate(eventDetailViewModelProvider(widget.eventId)),
      );
    }

    return const CatchErrorScaffold(
      title: 'Event not found',
      message: 'This event is no longer available.',
    );
  }

  bool get _initialEventMatchesRoute =>
      widget.initialEvent != null &&
      widget.initialEvent!.id == widget.eventId &&
      widget.initialEvent!.clubId == widget.clubId;

  Widget _buildBody(EventDetailViewModel vm) {
    return EventDetailBody(
      event: vm.event,
      userProfile: vm.userProfile,
      clubId: widget.clubId,
      reviews: vm.reviews,
      isAuthenticated: vm.isAuthenticated,
      isHost: vm.isHost,
      isSaved: vm.isSaved,
      participation: vm.participation,
      inviteCode: widget.inviteCode,
      inviteLinkId: widget.inviteLinkId,
      presentationMode: widget.presentationMode,
      heroTag: widget.heroTag,
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
      clubId: widget.clubId,
      reviews: reviews,
      isAuthenticated: isAuthenticated,
      isHost:
          AppConfig.appRole.isHost &&
          currentUid != null &&
          club?.isHostedBy(currentUid) == true,
      isSaved: savedEvent != null,
      participation: participation,
      inviteCode: widget.inviteCode,
      inviteLinkId: widget.inviteLinkId,
      presentationMode: widget.presentationMode,
      heroTag: widget.heroTag,
    );
  }
}
