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
          title: 'The plan',
          activityKind: event.activityKind,
          lead: true,
          first: true,
          dividerColor: style?.dividerColor,
          child: EventDescription(
            description: description.isEmpty
                ? _fallbackPlan(event)
                : description,
            surfaceStyle: style,
          ),
        ),
        CatchSection.divided(
          title: 'Why you might click',
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
                'Based on event format, capacity and booking rules — never shown to the group.',
                style: CatchTextStyles.supporting(
                  context,
                  color: style?.bodyColor,
                ),
              ),
            ],
          ),
        ),
        CatchSection.divided(
          title: 'Itinerary',
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
            title: 'Photos',
            dividerColor: style?.dividerColor,
            titleColor: style?.headingColor,
            child: EventDetailPhotoStrip(event: event),
          ),
        CatchSection.divided(
          title: 'Where',
          dividerColor: style?.dividerColor,
          titleColor: style?.headingColor,
          child: EventDetailMapCard(
            event: event,
            onTap: onLocationTap,
            borderColor: style?.borderColor,
          ),
        ),
        CatchSection.divided(
          title: 'How sign-ups work',
          dividerColor: style?.dividerColor,
          titleColor: style?.headingColor,
          child: EventDetailMechanismList(
            event: event,
            dividerColor: style?.dividerColor,
          ),
        ),
        CatchSection.divided(
          title: 'Good to know',
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
          'About this event',
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

String _fallbackPlan(Event event) {
  if (event.eventFormat.isDistanceBased) {
    return 'A ${EventFormatters.distanceKm(event.distanceKm)} ${event.eventFormat.label.toLowerCase()} at a ${event.pace.label.toLowerCase()} pace from ${event.locationName}.';
  }
  return 'A hosted ${event.eventFormat.label.toLowerCase()} built around a clear arrival, shared activity, and low-pressure follow-up.';
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
    final items = _expectationItems(event);

    return CatchSection.contained(
      title: 'What to expect',
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
      title: 'Booking policy',
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
            title: _admissionTitle(policy.admissionPolicy),
            body: _admissionSummary(policy.admissionPolicy),
          ),
          if (policy.usesDemandPricing)
            EventDetailPolicySummaryLine(
              icon: CatchIcons.trendingUpRounded,
              title: 'Demand pricing',
              body: _dynamicPricingSummary(
                policy.pricingPolicy,
                currencyCode: event.currency,
              ),
            ),
          EventDetailPolicySummaryLine(
            icon: CatchIcons.receiptLongOutlined,
            title: '${cancellation.title} cancellation',
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

List<_ExpectationItem> _expectationItems(Event event) {
  final policy = event.effectiveEventPolicy;
  final items = <_ExpectationItem>[
    _ExpectationItem(
      icon: _activityExpectationIcon(event),
      title: _activityExpectationTitle(event),
      body: _activityExpectationBody(event),
    ),
    _ExpectationItem(
      icon: CatchIcons.qrCode2Outlined,
      title: 'Attendance matters',
      body:
          'Check-in or host-marked attendance decides who can use post-event follow-up and feedback.',
    ),
  ];

  if (policy.admissionPolicy.manualApprovalRequired) {
    items.add(
      _ExpectationItem(
        icon: CatchIcons.pendingActionsOutlined,
        title: 'Host review',
        body:
            'Request a spot first. The host can review your public profile before confirming the roster.',
      ),
    );
  } else if (policy.admissionPolicy.format ==
      EventAdmissionFormat.balancedRatio) {
    items.add(
      _ExpectationItem(
        icon: CatchIcons.balanceOutlined,
        title: 'Balanced booking',
        body:
            'Some bookings may move through the waitlist so the event does not become too skewed.',
      ),
    );
  } else if (policy.admissionPolicy.waitlistPolicy.isEnabled) {
    items.add(
      _ExpectationItem(
        icon: CatchIcons.pendingActionsOutlined,
        title: 'Waitlist available',
        body:
            'If the event fills up, the waitlist can reopen spots when capacity changes.',
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

String _activityExpectationTitle(Event event) {
  if (event.eventFormat.isDistanceBased) {
    return '${event.distanceKm.toStringAsFixed(1)} km ${event.pace.label.toLowerCase()} ${event.eventFormat.label.toLowerCase()}';
  }
  return event.eventFormat.label;
}

String _activityExpectationBody(Event event) {
  return switch (event.eventFormat.interactionModel) {
    EventInteractionModel.pacePods =>
      'Arrive ready for the listed pace and route. The host may split attendees into smaller groups if the crowd needs structure.',
    EventInteractionModel.pairedRotations =>
      'Expect paired or court-based rotations so attendees can meet more people without managing the logistics themselves.',
    EventInteractionModel.teamRotations =>
      'Expect team structure and host-led moments that create natural reasons to talk.',
    EventInteractionModel.seatedTable =>
      'Expect a seated format with table-level structure and host cues for easier conversation.',
    EventInteractionModel.freeFormMixer =>
      'Expect a looser social format with host nudges when the room needs more mixing.',
    EventInteractionModel.hostLedProgram =>
      'Expect a host-led activity with clear arrival, activity, and follow-up moments.',
    EventInteractionModel.openFormat =>
      'Expect the host to shape the format around the room and venue.',
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

String _admissionTitle(EventAdmissionPolicy policy) {
  return switch (policy.format) {
    EventAdmissionFormat.open => 'Open capacity',
    EventAdmissionFormat.inviteOnly => 'Invite only',
    EventAdmissionFormat.manualApproval => 'Request to join',
    EventAdmissionFormat.fixedCohortCaps => 'Open with cohort caps',
    EventAdmissionFormat.balancedRatio => 'Balanced singles',
    EventAdmissionFormat.membersOnly => 'Members only',
  };
}

String _admissionSummary(EventAdmissionPolicy policy) {
  return switch (policy.format) {
    EventAdmissionFormat.open =>
      'Attendees book until ${policy.capacityLimit} spots are filled.',
    EventAdmissionFormat.fixedCohortCaps =>
      'Attendees book within total capacity, with optional straight men and straight women caps applied.',
    EventAdmissionFormat.balancedRatio =>
      'Straight men and women are balanced within a small tolerance; other cohorts book within total capacity.',
    EventAdmissionFormat.inviteOnly =>
      'Only attendees with the host invite can book.',
    EventAdmissionFormat.manualApproval =>
      'The host reviews requests before confirming spots.',
    EventAdmissionFormat.membersOnly =>
      'Only active club members can book this event.',
  };
}

String _dynamicPricingSummary(
  EventPricingPolicy policy, {
  required String currencyCode,
}) {
  if (policy.demandPricingRules.isEmpty) {
    return 'Price can change based on live demand.';
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
  return 'Price can increase by $step per demand step, capped at $max above the base price.';
}
