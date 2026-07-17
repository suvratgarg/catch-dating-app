import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_detail_information_state.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_design_primitives.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class EventDetailOverviewSection extends StatelessWidget {
  const EventDetailOverviewSection({
    super.key,
    required this.event,
    required this.informationState,
    this.onLocationTap,
    this.surfaceStyle,
    this.enableMapNetworkTiles = true,
  });

  final Event event;
  final EventDetailInformationState informationState;
  final VoidCallback? onLocationTap;
  final EventDetailSurfaceStyle? surfaceStyle;
  final bool enableMapNetworkTiles;

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
            enableNetworkTiles: enableMapNetworkTiles,
          ),
        ),
        CatchSection.divided(
          title:
              context.l10n.eventsEventDetailOverviewSectionTitleHowSignUpsWork,
          dividerColor: style?.dividerColor,
          titleColor: style?.headingColor,
          child: EventDetailMechanismList(
            rows: informationState.signUpRows,
            activityKind: informationState.activityKind,
            dividerColor: style?.dividerColor,
            titleColor: style?.headingColor,
            bodyColor: style?.bodyColor,
          ),
        ),
        CatchSection.divided(
          title: context.l10n.eventsEventDetailOverviewSectionTitleGoodToKnow,
          dividerColor: style?.dividerColor,
          titleColor: style?.headingColor,
          child: EventDetailGoodToKnowList(
            rows: informationState.goodToKnowRows,
            activityKind: informationState.activityKind,
            dividerColor: style?.dividerColor,
            titleColor: style?.headingColor,
            bodyColor: style?.bodyColor,
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
