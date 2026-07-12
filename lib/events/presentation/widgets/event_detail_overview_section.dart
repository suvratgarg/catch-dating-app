import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_design_primitives.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/events/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class EventDetailOverviewSection extends StatelessWidget {
  const EventDetailOverviewSection({
    super.key,
    required this.event,
    this.onLocationTap,
    this.surfaceStyle,
  });

  final Event event;
  final VoidCallback? onLocationTap;
  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    final description = event.description.trim();
    final style = surfaceStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchSection.divided(
          title: context.l10n.eventsEventDetailOverviewSectionTitleThePlan,
          activityKind: event.activityKind,
          lead: true,
          first: true,
          dividerColor: style?.dividerColor,
          child: EventDescription(
            description: description.isEmpty
                ? _fallbackPlan(event, context.l10n)
                : description,
            surfaceStyle: style,
          ),
        ),
        CatchSection.divided(
          title: context
              .l10n
              .eventsEventDetailOverviewSectionTitleWhyYouMightClick,
          dividerColor: style?.dividerColor,
          titleColor: style?.headingColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventDetailHintList(
                event: event,
                textColor: style?.headingColor,
                dividerColor: style?.dividerColor,
              ),
              gapH12,
              Text(
                context
                    .l10n
                    .eventsEventDetailOverviewSectionTextBasedOnEventFormat,
                style: CatchTextStyles.supporting(
                  context,
                  color: style?.bodyColor,
                ),
              ),
            ],
          ),
        ),
        CatchSection.divided(
          title: context.l10n.eventsEventDetailOverviewSectionTitleItinerary,
          dividerColor: style?.dividerColor,
          titleColor: style?.headingColor,
          child: EventDetailItinerary(
            event: event,
            titleColor: style?.headingColor,
            detailColor: style?.bodyColor,
            dotBackgroundColor: style?.surfaceBackground,
          ),
        ),
        if (event.eventPhotos.isNotEmpty)
          CatchSection.divided(
            title: context.l10n.eventsEventDetailOverviewSectionTitlePhotos,
            dividerColor: style?.dividerColor,
            titleColor: style?.headingColor,
            child: EventDetailPhotoStrip(event: event),
          ),
        CatchSection.divided(
          title: context.l10n.eventsEventDetailOverviewSectionTitleWhere,
          dividerColor: style?.dividerColor,
          titleColor: style?.headingColor,
          child: EventDetailMapCard(
            event: event,
            onTap: onLocationTap,
            borderColor: style?.borderColor,
          ),
        ),
        CatchSection.divided(
          title:
              context.l10n.eventsEventDetailOverviewSectionTitleHowSignUpsWork,
          dividerColor: style?.dividerColor,
          titleColor: style?.headingColor,
          child: EventDetailMechanismList(
            event: event,
            dividerColor: style?.dividerColor,
          ),
        ),
        CatchSection.divided(
          title: context.l10n.eventsEventDetailOverviewSectionTitleGoodToKnow,
          dividerColor: style?.dividerColor,
          titleColor: style?.headingColor,
          child: CatchSectionList(
            gap: CatchLayout.detailScreenContentGap,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.hasRequirements)
                RequirementsRow(event: event, surfaceStyle: style),
              WhatToExpectSection(event: event, surfaceStyle: style),
              EventDetailPolicySummary(event: event, surfaceStyle: style),
            ],
          ),
        ),
      ],
    );
  }
}

class EventDescription extends StatelessWidget {
  const EventDescription({
    super.key,
    required this.description,
    this.surfaceStyle,
  });

  final String description;
  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.eventsEventDetailOverviewSectionTextAboutThisEvent,
          style: CatchTextStyles.sectionTitle(
            context,
            color: surfaceStyle?.headingColor,
          ),
        ),
        const SizedBox(height: CatchLayout.detailScreenSupportingGap),
        Text(
          description,
          style: CatchTextStyles.bodyLead(
            context,
            color: surfaceStyle?.bodyColor ?? t.ink2,
          ),
        ),
      ],
    );
  }
}

String _fallbackPlan(Event event, AppLocalizations l10n) {
  if (event.eventFormat.isDistanceBased) {
    return l10n
        .eventsEventDetailOverviewSectionVisiblecopyADistancekmTolowercaseAt(
          distanceKm: EventFormatters.distanceKm(event.distanceKm),
          toLowerCase: event.eventFormat.label.toLowerCase(),
          toLowerCase2: event.pace.label.toLowerCase(),
          locationName: event.locationName,
        );
  }
  return l10n
      .eventsEventDetailOverviewSectionVisiblecopyAHostedTolowercaseBuilt(
        toLowerCase: event.eventFormat.label.toLowerCase(),
      );
}

class WhatToExpectSection extends StatelessWidget {
  const WhatToExpectSection({
    super.key,
    required this.event,
    this.surfaceStyle,
  });

  final Event event;
  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final items = _expectationItems(event, context.l10n);

    return CatchSection.contained(
      title: context.l10n.eventsEventDetailOverviewSectionTitleWhatToExpect,
      titleColor: surfaceStyle?.headingColor,
      padding: CatchInsets.tileContentCompact,
      bodyGap: CatchLayout.detailScreenInlineRowGap,
      backgroundColor: surfaceStyle?.surfaceBackground,
      borderColor: surfaceStyle?.borderColor ?? t.line,
      elevation: CatchSurfaceElevation.none,
      child: CatchSectionList(
        gap: CatchLayout.detailScreenInlineRowGap,
        children: [
          for (final item in items)
            EventDetailPolicySummaryLine(
              icon: item.icon,
              title: item.title,
              body: item.body,
            ),
        ],
      ),
    );
  }
}

class EventDetailPolicySummary extends StatelessWidget {
  const EventDetailPolicySummary({
    super.key,
    required this.event,
    this.surfaceStyle,
  });

  final Event event;
  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final policy = event.effectiveEventPolicy;
    final cancellation = policy.cancellationPolicy;

    return CatchSection.contained(
      title: context.l10n.eventsEventDetailOverviewSectionTitleBookingPolicy,
      titleColor: surfaceStyle?.headingColor,
      padding: CatchInsets.tileContentCompact,
      bodyGap: CatchLayout.detailScreenInlineRowGap,
      backgroundColor: surfaceStyle?.surfaceBackground,
      borderColor: surfaceStyle?.borderColor ?? t.line,
      elevation: CatchSurfaceElevation.none,
      child: CatchSectionList(
        gap: CatchLayout.detailScreenInlineRowGap,
        children: [
          EventDetailPolicySummaryLine(
            icon: CatchIcons.groupOutlined,
            title: _admissionTitle(policy.admissionPolicy, context.l10n),
            body: _admissionSummary(policy.admissionPolicy, context.l10n),
          ),
          if (policy.usesDemandPricing)
            EventDetailPolicySummaryLine(
              icon: CatchIcons.trendingUpRounded,
              title: context
                  .l10n
                  .eventsEventDetailOverviewSectionTitleDemandPricing,
              body: _dynamicPricingSummary(
                policy.pricingPolicy,
                currencyCode: event.currency,
                l10n: context.l10n,
              ),
            ),
          EventDetailPolicySummaryLine(
            icon: CatchIcons.receiptLongOutlined,
            title: context.l10n
                .eventsEventDetailOverviewSectionTitleTitleCancellation(
                  title: cancellation.title,
                ),
            body: cancellation.attendeeSummary,
          ),
          EventDetailPolicySummaryLine(
            icon: CatchIcons.verifiedUserOutlined,
            title: policy.settlementPolicy.title,
            body: policy.settlementPolicy.summary,
          ),
        ],
      ),
    );
  }
}

class EventDetailPolicySummaryLine extends StatelessWidget {
  const EventDetailPolicySummaryLine({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchField.read(
      icon: icon,
      iconColor: t.primary,
      title: title,
      body: body,
    );
  }
}

List<_ExpectationItem> _expectationItems(Event event, AppLocalizations l10n) {
  final policy = event.effectiveEventPolicy;
  final items = <_ExpectationItem>[
    _ExpectationItem(
      icon: _activityExpectationIcon(event),
      title: _activityExpectationTitle(event, l10n),
      body: _activityExpectationBody(event, l10n),
    ),
    _ExpectationItem(
      icon: CatchIcons.qrCode2Outlined,
      title: l10n.eventsEventDetailOverviewSectionTitleAttendanceMatters,
      body: l10n.eventsEventDetailOverviewSectionBodyCheckInOrHost,
    ),
  ];

  if (policy.admissionPolicy.manualApprovalRequired) {
    items.add(
      _ExpectationItem(
        icon: CatchIcons.pendingActionsOutlined,
        title: l10n.eventsEventDetailOverviewSectionTitleHostReview,
        body: l10n.eventsEventDetailOverviewSectionBodyRequestASpotFirst,
      ),
    );
  } else if (policy.admissionPolicy.format ==
      EventAdmissionFormat.balancedRatio) {
    items.add(
      _ExpectationItem(
        icon: CatchIcons.balanceOutlined,
        title: l10n.eventsEventDetailOverviewSectionTitleBalancedBooking,
        body: l10n.eventsEventDetailOverviewSectionBodySomeBookingsMayMove,
      ),
    );
  } else if (policy.admissionPolicy.waitlistPolicy.isEnabled) {
    items.add(
      _ExpectationItem(
        icon: CatchIcons.pendingActionsOutlined,
        title: l10n.eventsEventDetailOverviewSectionTitleWaitlistAvailable,
        body: l10n.eventsEventDetailOverviewSectionBodyIfTheEventFills,
      ),
    );
  }

  return items;
}

IconData _activityExpectationIcon(Event event) {
  return event.eventFormat.isDistanceBased
      ? CatchIcons.directionsRunOutlined
      : CatchIcons.eventAvailableOutlined;
}

String _activityExpectationTitle(Event event, AppLocalizations l10n) {
  if (event.eventFormat.isDistanceBased) {
    return l10n
        .eventsEventDetailOverviewSectionVisiblecopyTostringasfixedKmTolowercaseTolowercase2(
          toStringAsFixed: event.distanceKm.toStringAsFixed(1),
          toLowerCase: event.pace.label.toLowerCase(),
          toLowerCase2: event.eventFormat.label.toLowerCase(),
        );
  }
  return event.eventFormat.label;
}

String _activityExpectationBody(Event event, AppLocalizations l10n) {
  return switch (event.eventFormat.interactionModel) {
    EventInteractionModel.pacePods =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyArriveReadyForThe,
    EventInteractionModel.pairedRotations =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyExpectPairedOrCourt,
    EventInteractionModel.teamRotations =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyExpectTeamStructureAnd,
    EventInteractionModel.seatedTable =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyExpectASeatedFormat,
    EventInteractionModel.freeFormMixer =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyExpectALooserSocial,
    EventInteractionModel.hostLedProgram =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyExpectAHostLed,
    EventInteractionModel.openFormat =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyExpectTheHostTo,
  };
}

class _ExpectationItem {
  const _ExpectationItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

String _admissionTitle(EventAdmissionPolicy policy, AppLocalizations l10n) {
  return switch (policy.format) {
    EventAdmissionFormat.open =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyOpenCapacity,
    EventAdmissionFormat.inviteOnly =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyInviteOnly,
    EventAdmissionFormat.manualApproval =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyRequestToJoin,
    EventAdmissionFormat.fixedCohortCaps =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyOpenWithCohortCaps,
    EventAdmissionFormat.balancedRatio =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyBalancedSingles,
    EventAdmissionFormat.membersOnly =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyMembersOnly,
  };
}

String _admissionSummary(EventAdmissionPolicy policy, AppLocalizations l10n) {
  return switch (policy.format) {
    EventAdmissionFormat.open =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyAttendeesBookUntilCapacitylimit(
        capacityLimit: policy.capacityLimit,
      ),
    EventAdmissionFormat.fixedCohortCaps =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyAttendeesBookWithinTotal,
    EventAdmissionFormat.balancedRatio =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyStraightMenAndWomen,
    EventAdmissionFormat.inviteOnly =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyOnlyAttendeesWithThe,
    EventAdmissionFormat.manualApproval =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyTheHostReviewsRequests,
    EventAdmissionFormat.membersOnly =>
      l10n.eventsEventDetailOverviewSectionVisiblecopyOnlyActiveClubMembers,
  };
}

String _dynamicPricingSummary(
  EventPricingPolicy policy, {
  required String currencyCode,
  required AppLocalizations l10n,
}) {
  if (policy.demandPricingRules.isEmpty) {
    return l10n.eventsEventDetailOverviewSectionVisiblecopyPriceCanChangeBased;
  }
  final rule = policy.demandPricingRules.first;
  final step = EventFormatters.priceInPaise(
    rule.stepAdjustment.inPaise,
    currencyCode: currencyCode,
  );
  final max = EventFormatters.priceInPaise(
    rule.maxAdjustment.inPaise,
    currencyCode: currencyCode,
  );
  return l10n.eventsEventDetailOverviewSectionVisiblecopyPriceCanIncreaseBy(
    step: step,
    max: max,
  );
}
