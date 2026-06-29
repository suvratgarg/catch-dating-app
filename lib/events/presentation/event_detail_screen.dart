import 'dart:async';

import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_body.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_optimistic_body.dart';
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
      return EventDetailOptimisticBody(
        event: widget.initialEvent!,
        clubId: widget.clubId,
        presentationMode: widget.presentationMode,
        heroTag: widget.heroTag,
        inviteCode: widget.inviteCode,
        inviteLinkId: widget.inviteLinkId,
      );
    }

    if (vmAsync.isLoading) {
      return EventDetailLoadingScreen(
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
}

class EventDetailLoadingScreen extends StatelessWidget {
  const EventDetailLoadingScreen({
    super.key,
    required this.presentationMode,
  });

  final EventDetailPresentationMode presentationMode;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isSpotlight =
        presentationMode == EventDetailPresentationMode.spotlightDark;

    return Scaffold(
      backgroundColor: isSpotlight ? t.ink : t.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: EventDetailHeroSkeleton(presentationMode: presentationMode),
          ),
          SliverToBoxAdapter(child: const EventDetailTicketStubSkeleton()),
          CatchDetailSliverSectionList(
            topPadding: CatchSpacing.screenPt,
            bottomPadding: CatchSpacing.screenPb,
            sections: [
              const EventDetailPlanSkeleton(),
              const EventDetailHintSkeleton(),
              const EventDetailItinerarySkeleton(),
              const EventDetailMapSkeleton(),
              const EventDetailMechanismSkeleton(),
              const EventDetailSocialSkeleton(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: AppConfig.appRole.isHost
          ? null
          : const EventDetailLoadingCta(),
    );
  }
}

class EventDetailHeroSkeleton extends StatelessWidget {
  const EventDetailHeroSkeleton({
    super.key,
    required this.presentationMode,
  });

  final EventDetailPresentationMode presentationMode;

  @override
  Widget build(BuildContext context) {
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

class EventDetailTicketStubSkeleton extends StatelessWidget {
  const EventDetailTicketStubSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Expanded(child: const TicketStubCellSkeleton()),
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
}

class TicketStubCellSkeleton extends StatelessWidget {
  const TicketStubCellSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class EventDetailPlanSkeleton extends StatelessWidget {
  const EventDetailPlanSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
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
}

class EventDetailHintSkeleton extends StatelessWidget {
  const EventDetailHintSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
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
}

class EventDetailItinerarySkeleton extends StatelessWidget {
  const EventDetailItinerarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
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
}

class EventDetailMapSkeleton extends StatelessWidget {
  const EventDetailMapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: 'Where',
      child: CatchSkeleton.card(height: CatchLayout.eventDetailMapCardHeight),
    );
  }
}

class EventDetailMechanismSkeleton extends StatelessWidget {
  const EventDetailMechanismSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
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
}

class EventDetailSocialSkeleton extends StatelessWidget {
  const EventDetailSocialSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
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
}

class EventDetailLoadingCta extends StatelessWidget {
  const EventDetailLoadingCta({super.key});

  @override
  Widget build(BuildContext context) {
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
}
