import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_design_primitives.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_hero_app_bar.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_overview_section.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Optimistic render of the event detail body, shown while the full
/// [eventDetailViewModelProvider] is still loading.
///
/// Renders the hero, ticket-stub, and overview sections from the raw [Event]
/// object without watching any Riverpod providers. User-specific features
/// (save, share, calendar, CTA) are disabled or routed to auth. The hosts and
/// social sections are shown as skeletons.
///
/// Once the view model resolves, this widget is replaced by [EventDetailBody].
class EventDetailOptimisticBody extends StatelessWidget {
  const EventDetailOptimisticBody({
    super.key,
    required this.event,
    required this.clubId,
    this.presentationMode = EventDetailPresentationMode.standard,
    this.heroTag,
    this.inviteCode,
    this.inviteLinkId,
  });

  final Event event;
  final String clubId;
  final EventDetailPresentationMode presentationMode;
  final Object? heroTag;
  final String? inviteCode;
  final String? inviteLinkId;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isSpotlightDark =
        presentationMode == EventDetailPresentationMode.spotlightDark;
    final style = isSpotlightDark
        ? EventDetailSurfaceStyle.dark(t)
        : EventDetailSurfaceStyle.light(
            t,
            useWhite: presentationMode == EventDetailPresentationMode.ticket,
          );

    return Scaffold(
      backgroundColor: style.pageBackground,
      body: CustomScrollView(
        slivers: [
          EventDetailHeroAppBar(
            event: event,
            isSaved: false,
            savePending: false,
            onBack: () => Navigator.of(context).pop(),
            onShare: (_) {},
            showAddToCalendar: false,
            onAddToCalendar: (_) {},
            presentationMode: presentationMode,
            heroTag: heroTag,
            onToggleSaved: _onToggleSaved(context),
          ),
          SliverToBoxAdapter(child: EventDetailTicketStubBand(event: event)),
          CatchDetailSliverSectionList(
            topPadding: CatchSpacing.screenPt,
            bottomPadding: CatchSpacing.screenPb,
            sections: [
              EventDetailOverviewSection(
                event: event,
                surfaceStyle: style,
                onLocationTap: event.hasExactStartingPoint
                    ? () => context.pushNamed(
                        Routes.eventLocationMapScreen.name,
                        pathParameters: {'eventId': event.id},
                      )
                    : null,
              ),
              const _OptimisticHostsSkeleton(),
              const _OptimisticSocialSkeleton(),
            ],
          ),
        ],
      ),
    );
  }

  VoidCallback _onToggleSaved(BuildContext context) {
    return () => context.go(
      Uri(
        path: Routes.authScreen.path,
        queryParameters: {
          'from': AppDeepLinks.inAppEventPath(
            clubId: clubId,
            eventId: event.id,
            inviteCode: inviteCode,
            inviteLinkId: inviteLinkId,
          ),
        },
      ).toString(),
    );
  }
}

class _OptimisticHostsSkeleton extends StatelessWidget {
  const _OptimisticHostsSkeleton();

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: 'Your hosts',
      child: Row(
        children: [
          CatchSkeleton.circle(size: CatchIcon.avatarLg),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchSkeleton.text(),
                gapH8,
                CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptimisticSocialSkeleton extends StatelessWidget {
  const _OptimisticSocialSkeleton();

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
