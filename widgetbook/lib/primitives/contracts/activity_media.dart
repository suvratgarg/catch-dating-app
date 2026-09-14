import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/shared/catch_club_cover.dart';
import 'package:catch_dating_app/clubs/shared/catch_organizer_poster.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_art.dart';
import 'package:catch_dating_app/core/widgets/catch_activity_map_pin.dart';
import 'package:catch_dating_app/core/widgets/catch_event_activity_cards.dart';
import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/shared/catch_map_preview.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/contract_preview.dart';

import '../../preview_layout_contracts.dart';

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchClubCover,
  path: '[Core primitives]/Media',
)
Widget catchClubCoverContractStates(BuildContext context) {
  final fallbackClub = Club(
    id: 'contract-cover-fallback',
    name: 'Sea Face Social',
    description: 'A social movement club.',
    location: 'Mumbai',
    area: 'Bandra',
    createdAt: DateTime(2026),
  );
  final photoClub = fallbackClub.copyWith(
    id: 'contract-cover-photo',
    imageUrl:
        'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=720&q=80',
  );
  return WidgetbookContractFrame(
    title: 'CatchClubCover',
    contractId: 'catch.club_cover',
    states: const ['photo', 'fallback', 'compact', 'error-fallback'],
    children: [
      WidgetbookContractStateCard(
        label: 'photo',
        child: SizedBox(
          width: WidgetbookPreviewLayout.clubCoverWidth,
          height: WidgetbookPreviewLayout.clubCoverHeight,
          child: CatchClubCover(club: photoClub),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'fallback',
        child: SizedBox(
          width: WidgetbookPreviewLayout.clubCoverWidth,
          height: WidgetbookPreviewLayout.clubCoverHeight,
          child: CatchClubCover(club: fallbackClub),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'compact',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.clubCoverCompactExtent,
          child: CatchClubCover(club: fallbackClub, compact: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchOrganizerPoster,
  path: '[Core primitives]/Media',
)
Widget catchOrganizerPosterContractStates(BuildContext context) {
  final club = Club(
    id: 'contract-organizer-poster',
    name: 'Sea Face Social',
    description: 'Bombay moves together.',
    location: 'Mumbai',
    area: 'Bandra',
    createdAt: DateTime(2026),
  );
  Widget poster({
    OrganizerPosterLayout layout = OrganizerPosterLayout.editorial,
    OrganizerPosterTreatment treatment = OrganizerPosterTreatment.paper,
  }) {
    return CatchOrganizerPoster(
      media: OrganizerPosterArtwork(club: club),
      kicker: 'Run club · Mumbai',
      title: club.name,
      tagline: club.description,
      meta: 'Every Saturday · 6:30 AM',
      layout: layout,
      treatment: treatment,
    );
  }

  return WidgetbookContractFrame(
    title: 'CatchOrganizerPoster',
    contractId: 'catch.organizer_poster',
    states: const [
      'editorial-paper',
      'photo-ink',
      'split-signal',
      'minimal-paper',
      'photo',
      'fallback-artwork',
      'with-footer',
      'long-copy',
    ],
    children: [
      WidgetbookContractStateCard(label: 'editorial-paper', child: poster()),
      WidgetbookContractStateCard(
        label: 'photo-ink',
        child: poster(
          layout: OrganizerPosterLayout.photo,
          treatment: OrganizerPosterTreatment.ink,
        ),
      ),
      WidgetbookContractStateCard(
        label: 'split-signal',
        child: poster(
          layout: OrganizerPosterLayout.split,
          treatment: OrganizerPosterTreatment.signal,
        ),
      ),
      WidgetbookContractStateCard(
        label: 'minimal-paper',
        child: poster(layout: OrganizerPosterLayout.minimal),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchPolaroid,
  path: '[Core primitives]/Media',
)
Widget catchPolaroidContractStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return WidgetbookContractFrame(
    title: 'CatchPolaroid',
    contractId: 'catch.person_polaroid',
    states: const [
      'photo',
      'fallback-artwork',
      'read-only',
      'reactable',
      'long-copy',
      'text-scale',
    ],
    children: [
      WidgetbookContractStateCard(
        label: 'read-only',
        child: CatchPolaroid(
          media: ColoredBox(
            color: t.primarySoft,
            child: Icon(
              CatchIcons.personRounded,
              size: CatchSpacing.s16,
              color: t.primary,
            ),
          ),
          kicker: 'Was at · Sundowner 5K',
          name: 'Maya, 29',
          meta: 'Designer · Bandra',
        ),
      ),
      WidgetbookContractStateCard(
        label: 'reactable',
        child: CatchPolaroid(
          media: ColoredBox(
            color: t.raised,
            child: Icon(
              CatchIcons.personRounded,
              size: CatchSpacing.s16,
              color: t.ink3,
            ),
          ),
          mediaOverlay: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: CatchInsets.contentDense,
              child: CatchBadge.solid(label: 'LIKE'),
            ),
          ),
          kicker: 'Crossed paths',
          name: 'A long profile name, 31',
          meta: 'Runner · Lower Parel',
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchActivityArt,
  path: '[Core primitives]/Activity',
)
Widget catchActivityArtContractStates(BuildContext context) {
  return WidgetbookContractFrame(
    title: 'CatchActivityArt',
    contractId: 'catch.activity_art',
    states: const [
      'default',
      'activity-kind-variants',
      'dim',
      'with-overlay-child',
      'custom-size',
    ],
    children: [
      const WidgetbookContractStateCard(
        label: 'default',
        child: CatchActivityArt(activityKind: ActivityKind.socialRun),
      ),
      const WidgetbookContractStateCard(
        label: 'activity-kind-variants',
        child: WidgetbookContractWrap(
          children: [
            SizedBox(
              width: WidgetbookPreviewLayout.activityArtPairWidth,
              child: CatchActivityArt(
                activityKind: ActivityKind.pickleball,
                height: WidgetbookPreviewLayout.activityArtPairHeight,
              ),
            ),
            SizedBox(
              width: WidgetbookPreviewLayout.activityArtPairWidth,
              child: CatchActivityArt(
                activityKind: ActivityKind.dinner,
                height: WidgetbookPreviewLayout.activityArtPairHeight,
              ),
            ),
          ],
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'dim',
        child: CatchActivityArt(activityKind: ActivityKind.pubQuiz, dim: true),
      ),
      WidgetbookContractStateCard(
        label: 'with-overlay-child',
        child: CatchActivityArt(
          activityKind: ActivityKind.cycling,
          dim: true,
          child: Padding(
            padding: CatchInsets.content,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: CatchBadge(label: 'Tonight', tone: CatchBadgeTone.gold),
            ),
          ),
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'custom-size',
        child: SizedBox(
          width: WidgetbookPreviewLayout.activityArtCustomWidth,
          child: CatchActivityArt(
            activityKind: ActivityKind.yoga,
            height: WidgetbookPreviewLayout.activityArtCustomHeight,
            radius: CatchRadius.md,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchMapPreview,
  path: '[Core primitives]/Product composites',
)
Widget catchMapPreviewContractStates(BuildContext context) {
  return const WidgetbookContractFrame(
    title: 'CatchMapPreview',
    contractId: 'catch.map_preview',
    states: [
      'exact-location',
      'missing-coordinate',
      'network-disabled',
      'android-lite-mode',
    ],
    children: [
      WidgetbookContractStateCard(
        label: 'exact-location / network-disabled',
        child: SizedBox(
          height: WidgetbookPreviewLayout.mediaPanelHeight,
          child: CatchMapPreview(
            coordinate: LocationCoordinate(19.076, 72.8777),
            fallbackLabel: 'Bandra meeting point',
            enableNetworkTiles: false,
          ),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'missing-coordinate',
        child: SizedBox(
          height: WidgetbookPreviewLayout.mediaPanelHeight,
          child: CatchMapPreview(
            coordinate: null,
            fallbackLabel: 'Location unavailable',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchEventCard,
  path: '[Core primitives]/Product composites',
)
Widget catchEventCardContractStates(BuildContext context) {
  return WidgetbookContractFrame(
    title: 'CatchEventCard',
    contractId: 'catch.event_card',
    states: const ['ticket', 'ticket-status', 'long-copy'],
    children: [
      const WidgetbookContractStateCard(
        label: 'ticket',
        child: CatchEventCard.ticket(
          title: 'Sundowner 5K',
          subtitle: 'Marine Drive',
          timeLabel: '7:30 PM',
          countdownLabel: 'Tonight',
          priceLabel: 'Free',
          capacityLabel: '18 going',
          activityKind: ActivityKind.socialRun,
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'ticket-status',
        child: CatchEventCard.ticket(
          title: 'Doubles ladder',
          subtitle: 'Versova Padel',
          timeLabel: '9:00 AM',
          countdownLabel: 'Tomorrow',
          priceLabel: '₹900',
          capacityLabel: '4 left',
          activityKind: ActivityKind.padel,
          statusLabel: 'Booked',
        ),
      ),
      const WidgetbookContractStateCard(
        label: 'long-copy',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: CatchEventCard.ticket(
            title: 'A very long event name that should wrap without clipping',
            subtitle: 'A long venue name near the waterfront',
            timeLabel: '7:30 PM',
            countdownLabel: 'This weekend',
            priceLabel: 'Free',
            capacityLabel: '18 going',
            activityKind: ActivityKind.socialRun,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: EventActivityStamp,
  path: '[Core primitives]/Product composites',
)
Widget eventActivityStampContractStates(BuildContext context) {
  return WidgetbookContractFrame(
    title: 'EventActivityStamp',
    contractId: 'catch.event_card.activity_stamp',
    states: const ['default', 'custom-size', 'activity-variants'],
    children: [
      WidgetbookContractStateCard(
        label: 'default',
        child: EventActivityStamp(
          visual: eventActivityVisual(ActivityKind.socialRun, context: context),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'custom-size',
        child: EventActivityStamp(
          visual: eventActivityVisual(ActivityKind.dinner, context: context),
          size: 64,
          iconSize: 30,
        ),
      ),
      WidgetbookContractStateCard(
        label: 'activity-variants',
        child: WidgetbookContractWrap(
          children: [
            EventActivityStamp(
              visual: eventActivityVisual(
                ActivityKind.socialRun,
                context: context,
              ),
            ),
            EventActivityStamp(
              visual: eventActivityVisual(
                ActivityKind.dinner,
                context: context,
              ),
            ),
            EventActivityStamp(
              visual: eventActivityVisual(
                ActivityKind.pickleball,
                context: context,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchEventThumbnailActivityFallback,
  path: '[Core primitives]/Media',
)
Widget catchEventThumbnailActivityFallbackContractStates(BuildContext context) {
  return const WidgetbookContractFrame(
    title: 'CatchEventThumbnailActivityFallback',
    contractId: 'catch.event_card.event_thumbnail.activity_fallback',
    states: ['run', 'dinner', 'large-icon'],
    children: [
      WidgetbookContractStateCard(
        label: 'activity fallbacks',
        child: WidgetbookContractWrap(
          children: [
            SizedBox(
              width: WidgetbookPreviewLayout.thumbnailWidth,
              height: WidgetbookPreviewLayout.thumbnailHeight,
              child: CatchEventThumbnailActivityFallback(
                activityKind: ActivityKind.socialRun,
              ),
            ),
            SizedBox(
              width: WidgetbookPreviewLayout.thumbnailWidth,
              height: WidgetbookPreviewLayout.thumbnailHeight,
              child: CatchEventThumbnailActivityFallback(
                activityKind: ActivityKind.dinner,
              ),
            ),
            SizedBox(
              width: WidgetbookPreviewLayout.thumbnailWidth,
              height: WidgetbookPreviewLayout.thumbnailHeight,
              child: CatchEventThumbnailActivityFallback(
                activityKind: ActivityKind.pickleball,
                iconSize: 92,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchActivityMapPin,
  path: '[Core primitives]/Activity',
)
Widget catchActivityMapPinContractStates(BuildContext context) {
  return const WidgetbookContractFrame(
    title: 'CatchActivityMapPin',
    contractId: 'catch.activity_map_pin',
    states: ['resting', 'selected', 'selected-label', 'custom-size'],
    children: [
      WidgetbookContractStateCard(
        label: 'resting',
        child: CatchActivityMapPin(activityKind: ActivityKind.socialRun),
      ),
      WidgetbookContractStateCard(
        label: 'selected',
        child: CatchActivityMapPin(
          activityKind: ActivityKind.pickleball,
          selected: true,
        ),
      ),
      WidgetbookContractStateCard(
        label: 'selected-label',
        child: CatchActivityMapPin(
          activityKind: ActivityKind.dinner,
          selected: true,
          label: 'Dinner',
        ),
      ),
      WidgetbookContractStateCard(
        label: 'custom-size',
        child: CatchActivityMapPin(
          activityKind: ActivityKind.pubQuiz,
          size: 44,
        ),
      ),
    ],
  );
}
