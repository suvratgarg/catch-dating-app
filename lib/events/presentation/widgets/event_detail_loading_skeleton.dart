import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class EventDetailLoadingScreen extends StatelessWidget {
  const EventDetailLoadingScreen({
    super.key,
    required this.presentationMode,
    this.showBottomNavigation = true,
  });

  final EventDetailPresentationMode presentationMode;
  final bool showBottomNavigation;

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
          const SliverToBoxAdapter(child: EventDetailTicketStubSkeleton()),
          const CatchDetailSliverSectionList(
            topPadding: CatchSpacing.screenPt,
            bottomPadding: CatchSpacing.screenPb,
            sections: [
              EventDetailPlanSkeleton(),
              EventDetailHintSkeleton(),
              EventDetailItinerarySkeleton(),
              EventDetailMapSkeleton(),
              EventDetailMechanismSkeleton(),
              EventDetailSocialSkeleton(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: showBottomNavigation
          ? const EventDetailLoadingCta()
          : null,
    );
  }
}

class EventDetailHeroSkeleton extends StatelessWidget {
  const EventDetailHeroSkeleton({super.key, required this.presentationMode});

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
                    const Expanded(child: TicketStubCellSkeleton()),
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
      title: context.l10n.eventsEventDetailLoadingSkeletonTitleThePlan,
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
      title: context.l10n.eventsEventDetailLoadingSkeletonTitleWhyYouMightClick,
      child: Column(
        children: [
          for (var index = 0; index < 3; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: CatchInsets.detailHintDotTop,
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
      title: context.l10n.eventsEventDetailLoadingSkeletonTitleItinerary,
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
                    children: [
                      CatchSkeleton.text(),
                      gapH8,
                      CatchSkeleton.text(),
                    ],
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
      title: context.l10n.eventsEventDetailLoadingSkeletonTitleWhere,
      child: CatchSkeleton.card(height: CatchLayout.eventDetailMapCardHeight),
    );
  }
}

class EventDetailMechanismSkeleton extends StatelessWidget {
  const EventDetailMechanismSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: context.l10n.eventsEventDetailLoadingSkeletonTitleHowSignUpsWork,
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
  const EventDetailSocialSkeleton({super.key, this.surfaceStyle});

  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: context.l10n.eventsEventDetailLoadingSkeletonTitleWhoSGoing,
      dividerColor: surfaceStyle?.dividerColor,
      titleColor: surfaceStyle?.headingColor,
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

class EventDetailCompanionSkeleton extends StatelessWidget {
  const EventDetailCompanionSkeleton({super.key, required this.surfaceStyle});

  final EventDetailSurfaceStyle surfaceStyle;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      backgroundColor: surfaceStyle.surfaceBackground,
      borderColor: surfaceStyle.borderColor,
      padding: CatchInsets.tileContentCompact,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.circle(size: CatchIcon.control),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
                gapH8,
                CatchSkeleton.textBlock(lines: 2),
                gapH12,
                CatchSkeleton.box(
                  width: double.infinity,
                  height: CatchLayout.buttonLgHeight,
                  radius: CatchRadius.pill,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailHostsSkeleton extends StatelessWidget {
  const EventDetailHostsSkeleton({super.key, this.surfaceStyle});

  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: context.l10n.eventsEventDetailBodyTitleHostedBy,
      dividerColor: surfaceStyle?.dividerColor,
      titleColor: surfaceStyle?.headingColor,
      child: Row(
        children: [
          CatchSkeleton.circle(size: CatchSpacing.s10),
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

class EventDetailLoadingCta extends StatelessWidget {
  const EventDetailLoadingCta({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchBottomAction(
      label: context.l10n.eventsEventDetailScreenStateLabelBookEvent,
      onPressed: null,
      isLoading: true,
    );
  }
}
