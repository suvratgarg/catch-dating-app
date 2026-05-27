import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_stats_grid.dart';
import 'package:catch_dating_app/events/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/events/presentation/widgets/when_where_card.dart';
import 'package:flutter/material.dart';

class EventDetailOverviewSection extends StatelessWidget {
  const EventDetailOverviewSection({
    super.key,
    required this.event,
    this.onLocationTap,
  });

  final Event event;
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    final description = event.description.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventStatsGrid(event: event),
        gapH20,
        WhenWhereCard(event: event, onLocationTap: onLocationTap),
        if (description.isNotEmpty) ...[
          gapH20,
          _EventDescription(description: description),
        ],
        if (event.hasRequirements) ...[gapH20, RequirementsRow(event: event)],
        gapH20,
        _WhatToExpectSection(event: event),
        gapH20,
        _EventPolicySummary(event: event),
      ],
    );
  }
}

class _EventDescription extends StatelessWidget {
  const _EventDescription({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About this event', style: CatchTextStyles.sectionTitle(context)),
        gapH8,
        Text(
          description,
          style: CatchTextStyles.bodyLead(context, color: t.ink2),
        ),
      ],
    );
  }
}

class _WhatToExpectSection extends StatelessWidget {
  const _WhatToExpectSection({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final items = _expectationItems(event);

    return CatchSurface(
      padding: const EdgeInsets.all(14),
      radius: CatchRadius.md,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What to expect', style: CatchTextStyles.sectionTitle(context)),
          gapH10,
          for (final item in items) ...[
            _PolicyLine(icon: item.icon, title: item.title, body: item.body),
            if (item != items.last) gapH10,
          ],
        ],
      ),
    );
  }
}

class _EventPolicySummary extends StatelessWidget {
  const _EventPolicySummary({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final policy = event.effectiveEventPolicy;
    final cancellation = policy.cancellationPolicy;

    return CatchSurface(
      padding: const EdgeInsets.all(14),
      radius: CatchRadius.md,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking policy', style: CatchTextStyles.sectionTitle(context)),
          gapH10,
          _PolicyLine(
            icon: CatchIcons.groupOutlined,
            title: _admissionTitle(policy.admissionPolicy),
            body: _admissionSummary(policy.admissionPolicy),
          ),
          if (policy.usesDemandPricing) ...[
            gapH10,
            _PolicyLine(
              icon: CatchIcons.trendingUpRounded,
              title: 'Demand pricing',
              body: _dynamicPricingSummary(
                policy.pricingPolicy,
                currencyCode: event.currency,
              ),
            ),
          ],
          gapH10,
          _PolicyLine(
            icon: CatchIcons.receiptLongOutlined,
            title: '${cancellation.title} cancellation',
            body: cancellation.attendeeSummary,
          ),
          gapH10,
          _PolicyLine(
            icon: CatchIcons.verifiedUserOutlined,
            title: policy.settlementPolicy.title,
            body: policy.settlementPolicy.summary,
          ),
        ],
      ),
    );
  }
}

class _PolicyLine extends StatelessWidget {
  const _PolicyLine({
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: t.primary, size: 18),
        gapW8,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CatchTextStyles.labelL(context)),
              gapH2,
              Text(
                body,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
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
