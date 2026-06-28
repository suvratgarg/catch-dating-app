import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
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
      return _eventDetailLoadingScreen(
        context,
        presentationMode: widget.presentationMode,
      );
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

Widget _eventDetailLoadingScreen(
  BuildContext context, {
  required EventDetailPresentationMode presentationMode,
}) {
  final t = CatchTokens.of(context);
  final isSpotlight =
      presentationMode == EventDetailPresentationMode.spotlightDark;

  return Scaffold(
    backgroundColor: isSpotlight ? t.ink : t.bg,
    body: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _eventDetailHeroSkeleton(
            context,
            presentationMode: presentationMode,
          ),
        ),
        SliverToBoxAdapter(child: _eventDetailTicketStubSkeleton(context)),
        CatchDetailSliverSectionList(
          topPadding: CatchSpacing.screenPt,
          bottomPadding: CatchSpacing.screenPb,
          sections: [
            _eventDetailPlanSkeleton(),
            _eventDetailHintSkeleton(),
            _eventDetailItinerarySkeleton(),
            _eventDetailMapSkeleton(),
            _eventDetailMechanismSkeleton(),
            _eventDetailSocialSkeleton(),
          ],
        ),
      ],
    ),
    bottomNavigationBar: AppConfig.appRole.isHost
        ? null
        : _eventDetailLoadingCta(context),
  );
}

Widget _eventDetailHeroSkeleton(
  BuildContext context, {
  required EventDetailPresentationMode presentationMode,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final height = _eventDetailLoadingHeroHeight(
    width: width,
    isTicketPresentation:
        presentationMode != EventDetailPresentationMode.standard,
  );

  return SizedBox(
    height: height,
    child: Stack(
      children: [
        Positioned.fill(
          child: CatchSkeleton.box(
            width: double.infinity,
            height: height,
            borderRadius: BorderRadius.zero,
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + CatchSpacing.s2,
          left: CatchSpacing.s2,
          right: CatchSpacing.s2,
          child: Row(
            children: [
              CatchSkeleton.circle(size: CatchIconButton.navSize),
              const Spacer(),
              CatchSkeleton.circle(size: CatchIconButton.navSize),
              gapW8,
              CatchSkeleton.circle(size: CatchIconButton.navSize),
            ],
          ),
        ),
        Positioned(
          left: CatchSpacing.s5,
          right: CatchSpacing.s5,
          bottom: CatchLayout.eventDetailHeroTitleBottomInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CatchSkeleton.box(
                width: CatchLayout.skeletonTextShortWidth,
                height: CatchIcon.sm,
                radius: CatchRadius.pill,
              ),
              gapH12,
              CatchSkeleton.text(),
              gapH8,
              CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
            ],
          ),
        ),
      ],
    ),
  );
}

double _eventDetailLoadingHeroHeight({
  required double width,
  required bool isTicketPresentation,
}) {
  if (isTicketPresentation) {
    return width > CatchLayout.maxContentWidth
        ? CatchLayout.eventDetailHeroTicketWideHeight
        : CatchLayout.eventDetailHeroTicketPhoneHeight;
  }

  if (width > CatchLayout.maxContentWidth) {
    return CatchLayout.eventDetailHeroStandardWideHeight;
  }

  return (width * CatchLayout.eventDetailHeroStandardHeightRatio)
      .clamp(
        CatchLayout.eventDetailHeroStandardMinHeight,
        CatchLayout.eventDetailHeroStandardMaxHeight,
      )
      .toDouble();
}

Widget _eventDetailTicketStubSkeleton(BuildContext context) {
  final t = CatchTokens.of(context);

  return ColoredBox(
    color: t.surface,
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: CatchLayout.eventDetailTicketStubBandHeight,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var index = 0; index < 3; index++) ...[
                  if (index > 0) VerticalDivider(color: t.line, width: 1),
                  Expanded(child: _ticketStubCellSkeleton()),
                ],
              ],
            ),
          ),
          Divider(color: t.line, height: 1, thickness: 1),
        ],
      ),
    ),
  );
}

Widget _ticketStubCellSkeleton() {
  return Padding(
    padding: CatchInsets.tileContentCompact,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
        gapH8,
        CatchSkeleton.box(
          width: CatchLayout.skeletonTextTitleWidth,
          height: CatchIcon.sm,
          radius: CatchRadius.pill,
        ),
      ],
    ),
  );
}

Widget _eventDetailPlanSkeleton() {
  return CatchSection(
    title: 'The plan',
    first: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
        gapH12,
        CatchSkeleton.textBlock(),
      ],
    ),
  );
}

Widget _eventDetailHintSkeleton() {
  return CatchSection(
    title: 'Why you might click',
    child: Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: CatchSpacing.s1),
                child: CatchSkeleton.circle(
                  size: CatchLayout.eventDetailHintDotExtent,
                ),
              ),
              gapW12,
              Expanded(child: CatchSkeleton.text()),
            ],
          ),
          if (index < 2) gapH12,
        ],
        gapH12,
        CatchSkeleton.text(),
      ],
    ),
  );
}

Widget _eventDetailItinerarySkeleton() {
  return CatchSection(
    title: 'Itinerary',
    child: Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CatchSkeleton.text(
                width: CatchLayout.eventDetailItineraryTimeColumnWidth,
              ),
              gapW12,
              CatchSkeleton.circle(
                size: CatchLayout.eventDetailItineraryDotExtent,
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [CatchSkeleton.text(), gapH8, CatchSkeleton.text()],
                ),
              ),
            ],
          ),
          if (index < 2) gapH16,
        ],
      ],
    ),
  );
}

Widget _eventDetailMapSkeleton() {
  return CatchSection(
    title: 'Where',
    child: CatchSkeleton.card(height: CatchLayout.eventDetailMapCardHeight),
  );
}

Widget _eventDetailMechanismSkeleton() {
  return CatchSection(
    title: 'How sign-ups work',
    child: Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          Row(
            children: [
              CatchSkeleton.box(
                width: CatchIcon.control,
                height: CatchIcon.control,
                radius: CatchRadius.pill,
              ),
              gapW12,
              Expanded(child: CatchSkeleton.text()),
            ],
          ),
          if (index < 2) gapH16,
        ],
      ],
    ),
  );
}

Widget _eventDetailSocialSkeleton() {
  return CatchSection(
    title: "Who's going",
    child: Row(
      children: [
        for (var index = 0; index < 4; index++) ...[
          CatchSkeleton.circle(size: CatchIcon.avatarLg),
          if (index < 3) gapW8,
        ],
        gapW16,
        Expanded(child: CatchSkeleton.text()),
      ],
    ),
  );
}

Widget _eventDetailLoadingCta(BuildContext context) {
  final t = CatchTokens.of(context);

  return ColoredBox(
    color: t.surface,
    child: SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        CatchLayout.detailScreenHorizontalPadding,
        CatchSpacing.s3,
        CatchLayout.detailScreenHorizontalPadding,
        CatchSpacing.s3,
      ),
      child: CatchSkeleton.box(
        width: double.infinity,
        height: CatchLayout.buttonLgHeight,
        radius: CatchRadius.pill,
      ),
    ),
  );
}
