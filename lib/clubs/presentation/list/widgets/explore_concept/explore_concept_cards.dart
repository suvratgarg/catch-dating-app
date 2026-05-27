import 'dart:math' as math;

import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_activity_visuals.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_models.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _ticketMediaHeight = 136.0;
const _ticketDividerHeight = 20.0;
const _ticketNotchRadius = 10.0;
const _ticketNotchDepth = 8.0;
const _clubSpotlightWidth = 420.0;
const _clubSpotlightHeight = 400.0;
const _clubPhotoSpotlightImageHeight = 252.0;

class ExploreConceptEventTicketCard extends StatelessWidget {
  const ExploreConceptEventTicketCard({
    super.key,
    required this.event,
    this.width = 276,
    this.onTap,
  });

  final ExploreConceptEventData event;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = exploreConceptActivityVisual(event.activityKind);
    return SizedBox(
      width: width,
      child: PhysicalShape(
        clipper: const _TicketShapeClipper(
          cornerRadius: CatchRadius.lg,
          notchRadius: _ticketNotchRadius,
          notchDepth: _ticketNotchDepth,
          notchCenterY: _ticketMediaHeight + _ticketDividerHeight / 2,
        ),
        clipBehavior: Clip.antiAlias,
        color: t.surface,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.18),
        child: CatchSurface(
          onTap: onTap,
          padding: EdgeInsets.zero,
          radius: CatchRadius.lg,
          elevation: CatchSurfaceElevation.none,
          clipBehavior: Clip.none,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: _ticketMediaHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ExploreConceptActivityBackdrop(visual: visual),
                    Positioned(
                      left: CatchSpacing.s4,
                      bottom: CatchSpacing.s4,
                      child: _OutlineStamp(label: event.statusLabel),
                    ),
                    Positioned(
                      top: CatchSpacing.s3,
                      right: CatchSpacing.s3,
                      child: _SoftIconBadge(icon: CatchIcons.bookmarkRounded),
                    ),
                  ],
                ),
              ),
              const _TicketPerforatedDivider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s4,
                  CatchSpacing.s3,
                  CatchSpacing.s4,
                  CatchSpacing.s4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _ClockMark(
                          accent: visual.accent,
                          time: _clockTimeFor(event),
                        ),
                        gapW10,
                        Expanded(
                          child: _MonoLabel(
                            '${event.timeLabel}  /  ${event.countdownLabel}',
                            color: t.primary,
                          ),
                        ),
                        gapW8,
                        Text(
                          event.priceLabel,
                          style: CatchTextStyles.labelL(context, color: t.ink),
                        ),
                      ],
                    ),
                    gapH10,
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _serif(context, size: 24, height: 1.02),
                    ),
                    gapH6,
                    Text(
                      '${event.clubName} - ${event.venue}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                    gapH12,
                    _MonoLabel(event.capacityLabel, color: t.ink2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreConceptEventSpotlightCard extends StatelessWidget {
  const ExploreConceptEventSpotlightCard({
    super.key,
    required this.event,
    this.kicker = "This week's pick",
    this.onTap,
  });

  final ExploreConceptEventData event;
  final String kicker;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = exploreConceptActivityVisual(event.activityKind);
    return CatchSurface(
      onTap: onTap,
      padding: EdgeInsets.zero,
      radius: CatchRadius.lg,
      borderColor: t.line2,
      elevation: CatchSurfaceElevation.card,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ExploreConceptActivityBackdrop(
                  visual: visual,
                  dense: true,
                  iconSize: 180,
                  iconOpacity: 0.16,
                  patternOpacity: 0.26,
                ),
                Positioned(
                  top: CatchSpacing.s4,
                  left: CatchSpacing.s4,
                  child: _RoundGlyph(icon: visual.icon, color: visual.accent),
                ),
                Positioned(
                  top: CatchSpacing.s4,
                  right: CatchSpacing.s4,
                  child: _DarkTimeChip(
                    label: event.timeLabel,
                    sublabel: event.countdownLabel,
                  ),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(color: t.ink),
            child: Padding(
              padding: const EdgeInsets.all(CatchSpacing.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MonoLabel(
                    kicker.toUpperCase(),
                    color: t.primarySoft.withValues(alpha: 0.72),
                  ),
                  gapH8,
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _serif(
                      context,
                      size: 30,
                      height: 1.0,
                      color: t.primaryInk,
                    ),
                  ),
                  gapH10,
                  Text(
                    event.supportingLabel ??
                        '${event.clubName} - ${event.venue}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.bodyM(
                      context,
                      color: t.primaryInk.withValues(alpha: 0.76),
                    ),
                  ),
                  gapH16,
                  Row(
                    children: [
                      _AvatarStack(accent: visual.accent),
                      gapW10,
                      Expanded(
                        child: _MonoLabel(
                          event.capacityLabel,
                          color: t.primaryInk.withValues(alpha: 0.82),
                        ),
                      ),
                      Text(
                        event.priceLabel,
                        style: CatchTextStyles.labelL(
                          context,
                          color: t.primaryInk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreConceptClubSpotlightCard extends StatelessWidget {
  const ExploreConceptClubSpotlightCard({
    super.key,
    required this.club,
    this.width = _clubSpotlightWidth,
  });

  final ExploreConceptClubData club;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: _clubSpotlightHeight,
      child: club.hasCoverPhoto
          ? _ClubPhotoSpotlightCard(club: club)
          : _ClubIdentitySpotlightCard(club: club),
    );
  }
}

class _ClubPhotoSpotlightCard extends StatelessWidget {
  const _ClubPhotoSpotlightCard({required this.club});

  final ExploreConceptClubData club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      radius: CatchRadius.sm,
      borderColor: t.line,
      elevation: CatchSurfaceElevation.card,
      backgroundColor: t.surface,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(CatchRadius.sm),
              child: SizedBox(
                height: _clubPhotoSpotlightImageHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _ClubCoverPhotoMock(
                      accent: club.accentColor,
                      secondaryAccent: club.secondaryAccentColor,
                    ),
                    Positioned(
                      top: CatchSpacing.s3,
                      left: CatchSpacing.s3,
                      child: _MiniClubCrest(color: club.accentColor),
                    ),
                    Positioned(
                      top: CatchSpacing.s3,
                      right: CatchSpacing.s3,
                      child: _PhotoMemberSeal(label: club.memberCountLabel),
                    ),
                  ],
                ),
              ),
            ),
            gapH8,
            _MonoLabel(
              (club.coverCaption ?? club.kicker).toUpperCase(),
              color: t.ink3,
            ),
            gapH2,
            Text(
              club.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _serif(context, size: 29, height: 0.98),
            ),
            gapH2,
            Text(
              club.tagline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
            gapH8,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _PhotoClubHostLine(
                    club: club,
                    hostLabel: club.hostLabel,
                  ),
                ),
                const SizedBox(width: CatchSpacing.s3),
                _DarkPill(label: club.actionLabel, compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubIdentitySpotlightCard extends StatelessWidget {
  const _ClubIdentitySpotlightCard({required this.club});

  final ExploreConceptClubData club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      radius: CatchRadius.sm,
      borderColor: t.line,
      elevation: CatchSurfaceElevation.card,
      backgroundColor: t.surface,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ClubCrest(color: club.accentColor),
                const SizedBox(width: CatchSpacing.micro18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MonoLabel(club.kicker.toUpperCase(), color: t.ink3),
                      gapH4,
                      Text(
                        club.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _serif(context, size: 32, height: 0.98),
                      ),
                      gapH8,
                      Text(
                        club.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.bodyLead(context, color: t.ink2),
                      ),
                    ],
                  ),
                ),
                gapW12,
                _CircularSeal(label: club.memberCountLabel),
              ],
            ),
            gapH18,
            _ClubRule(color: t.line),
            gapH16,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _HostInitials(
                  firstColor: club.accentColor,
                  secondColor: club.secondaryAccentColor,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MonoLabel('HOSTED BY', color: t.ink3),
                      gapH2,
                      Text(
                        club.hostLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.titleM(context, color: t.ink),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            gapH16,
            _ClubRule(color: t.line),
            gapH16,
            _ClubTagsActionRow(club: club),
          ],
        ),
      ),
    );
  }
}

class ExploreConceptThisWeekList extends StatelessWidget {
  const ExploreConceptThisWeekList({super.key, required this.items});

  final List<ExploreConceptThisWeekItemData> items;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      radius: CatchRadius.sm,
      borderColor: t.line,
      backgroundColor: t.surface.withValues(alpha: 0.72),
      elevation: CatchSurfaceElevation.none,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index += 1) ...[
            switch (items[index]) {
              final ExploreConceptThisWeekEventData event => _ThisWeekEventRow(
                event: event,
              ),
              final ExploreConceptThisWeekClubData club => _ThisWeekClubRow(
                club: club,
              ),
            },
            if (index != items.length - 1) _ThisWeekDivider(color: t.line),
          ],
        ],
      ),
    );
  }
}

class _ThisWeekEventRow extends StatelessWidget {
  const _ThisWeekEventRow({required this.event});

  final ExploreConceptThisWeekEventData event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = exploreConceptActivityVisual(event.activityKind);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s4,
        vertical: CatchSpacing.s4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ThisWeekDateBadge(
            weekdayLabel: event.weekdayLabel,
            dayLabel: event.dayLabel,
          ),
          gapW14,
          _ThisWeekActivityStamp(visual: visual),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MonoLabel(event.clubName.toUpperCase(), color: t.ink3),
                gapH6,
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _serif(context, size: 28, height: 0.98),
                ),
                gapH8,
                Row(
                  children: [
                    _TinyClockMark(
                      accent: visual.accent,
                      time:
                          event.clockTime ??
                          _parseClockTimeLabel(event.timeLabel),
                    ),
                    gapW8,
                    Flexible(
                      child: Text(
                        '${event.timeLabel}  /  ${event.priceLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.mono(context, color: t.ink2),
                      ),
                    ),
                  ],
                ),
                gapH8,
                Row(
                  children: [
                    Text(
                      event.goingLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.mono(
                        context,
                        color: t.ink,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '  -  ',
                      style: CatchTextStyles.mono(context, color: t.ink3),
                    ),
                    Text(
                      event.leftLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.mono(
                        context,
                        color: event.leftIsUrgent ? visual.accent : t.ink3,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                    gapW12,
                    Expanded(
                      child: _ThisWeekProgress(
                        color: visual.accent,
                        value: event.progress,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          gapW14,
          _ThisWeekAccentRail(color: visual.accent),
        ],
      ),
    );
  }
}

class _ThisWeekClubRow extends StatelessWidget {
  const _ThisWeekClubRow({required this.club});

  final ExploreConceptThisWeekClubData club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = exploreConceptActivityVisual(club.activityKind);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s4,
        vertical: CatchSpacing.s5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ThisWeekClubStamp(visual: visual),
          gapW20,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MonoLabel(club.kicker.toUpperCase(), color: t.accent),
                gapH4,
                Text(
                  club.club.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _serif(context, size: 28, height: 0.98),
                ),
                gapH4,
                Text(
                  club.supportingLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.bodyM(context, color: t.ink2),
                ),
              ],
            ),
          ),
          gapW16,
          _DarkPill(label: club.club.actionLabel, compact: true),
        ],
      ),
    );
  }
}

class _ThisWeekDateBadge extends StatelessWidget {
  const _ThisWeekDateBadge({
    required this.weekdayLabel,
    required this.dayLabel,
  });

  final String weekdayLabel;
  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      width: 60,
      height: 76,
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(CatchRadius.md),
        border: Border.all(color: t.line2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MonoLabel(weekdayLabel.toUpperCase(), color: t.ink3),
          gapH2,
          Text(dayLabel, style: _serif(context, size: 30, height: 0.9)),
        ],
      ),
    );
  }
}

class _ThisWeekActivityStamp extends StatelessWidget {
  const _ThisWeekActivityStamp({required this.visual});

  final ExploreConceptActivityVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: visual.accent,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: CatchElevation.card,
      ),
      child: Icon(visual.icon, color: Colors.white, size: 20),
    );
  }
}

class _ThisWeekClubStamp extends StatelessWidget {
  const _ThisWeekClubStamp({required this.visual});

  final ExploreConceptActivityVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [visual.deep, visual.accent],
        ),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: CatchElevation.card,
      ),
      child: Icon(visual.icon, color: Colors.white, size: 32),
    );
  }
}

class _TinyClockMark extends StatelessWidget {
  const _TinyClockMark({required this.accent, required this.time});

  final Color accent;
  final TimeOfDay time;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox.square(
      dimension: 22,
      child: CustomPaint(
        painter: _ClockPainter(ring: t.ink3, hand: accent, time: time),
      ),
    );
  }
}

class _ThisWeekProgress extends StatelessWidget {
  const _ThisWeekProgress({required this.color, required this.value});

  final Color color;
  final double value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final clamped = value.clamp(0, 1).toDouble();
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.pill),
      child: SizedBox(
        height: 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: t.line.withValues(alpha: 0.55)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: ColoredBox(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThisWeekAccentRail extends StatelessWidget {
  const _ThisWeekAccentRail({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 108,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(CatchRadius.pill),
      ),
    );
  }
}

class _ThisWeekDivider extends StatelessWidget {
  const _ThisWeekDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
      child: _ClubRule(color: color),
    );
  }
}

class ExploreConceptEventDetailHeaderMock extends StatelessWidget {
  const ExploreConceptEventDetailHeaderMock({
    super.key,
    required this.event,
    this.onTap,
  });

  final ExploreConceptEventData event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = exploreConceptActivityVisual(event.activityKind);
    return CatchSurface(
      onTap: onTap,
      padding: EdgeInsets.zero,
      radius: CatchRadius.lg,
      borderColor: t.line2,
      elevation: CatchSurfaceElevation.card,
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExploreConceptActivityBackdrop(
              visual: visual,
              dense: true,
              iconAlignment: Alignment.topRight,
              iconSize: 180,
              iconOpacity: 0.17,
              patternOpacity: 0.24,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.68),
                  ],
                  stops: const [0.0, 0.48, 1.0],
                ),
              ),
            ),
            Positioned(
              left: CatchSpacing.s5,
              right: CatchSpacing.s5,
              bottom: CatchSpacing.s5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OutlineStamp(label: visual.label),
                  gapH10,
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _serif(
                      context,
                      size: 34,
                      height: 0.98,
                      color: Colors.white,
                    ),
                  ),
                  gapH8,
                  Text(
                    '${event.clubName} - ${event.venue} - ${event.timeLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.bodyM(
                      context,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketPerforatedDivider extends StatelessWidget {
  const _TicketPerforatedDivider();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      height: _ticketDividerHeight,
      child: CustomPaint(
        painter: _TicketPerforationPainter(lineColor: t.line2),
      ),
    );
  }
}

class _OutlineStamp extends StatelessWidget {
  const _OutlineStamp({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Transform.rotate(
      angle: -0.08,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: t.accent, width: 1.5),
          color: t.primaryInk.withValues(alpha: 0.12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CatchSpacing.s2,
            vertical: CatchSpacing.s1,
          ),
          child: _MonoLabel(label.toUpperCase(), color: t.accent),
        ),
      ),
    );
  }
}

class _SoftIconBadge extends StatelessWidget {
  const _SoftIconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(CatchRadius.md),
      ),
      child: Icon(icon, size: 20, color: t.ink),
    );
  }
}

class _ClockMark extends StatelessWidget {
  const _ClockMark({required this.accent, required this.time});

  final Color accent;
  final TimeOfDay time;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox.square(
      dimension: 38,
      child: CustomPaint(
        painter: _ClockPainter(ring: t.ink2, hand: accent, time: time),
      ),
    );
  }
}

class _DarkTimeChip extends StatelessWidget {
  const _DarkTimeChip({required this.label, required this.sublabel});

  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(CatchRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.s2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _MonoLabel(sublabel.toUpperCase(), color: Colors.white70),
            gapH2,
            Text(
              label,
              style: CatchTextStyles.titleM(
                context,
                color: Colors.white,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundGlyph extends StatelessWidget {
  const _RoundGlyph({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.42)),
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = [accent, CatchTokens.of(context).gold, Colors.teal];
    return SizedBox(
      width: 70,
      height: 28,
      child: Stack(
        children: [
          for (var index = 0; index < colors.length; index += 1)
            Positioned(
              left: index * 20,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: colors[index],
                child: Text(
                  String.fromCharCode(65 + index),
                  style: _serif(context, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClubCoverPhotoMock extends StatelessWidget {
  const _ClubCoverPhotoMock({
    required this.accent,
    required this.secondaryAccent,
  });

  final Color accent;
  final Color secondaryAccent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2F614F),
                secondaryAccent.withValues(alpha: 0.72),
                accent.withValues(alpha: 0.82),
                const Color(0xFFF3C778),
              ],
              stops: const [0.0, 0.34, 0.72, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 72,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.24),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 38,
          top: 24,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
        ),
        Positioned(
          left: 28,
          right: 28,
          bottom: 18,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              _PhotoPerson(height: 56, color: Color(0xFFF5E6D3)),
              _PhotoPerson(height: 68, color: Color(0xFFFFFFFF)),
              _PhotoPerson(height: 60, color: Color(0xFFEEC8A3)),
              _PhotoPerson(height: 64, color: Color(0xFFF9F0E6)),
            ],
          ),
        ),
        Positioned(
          left: -30,
          right: -30,
          bottom: 34,
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
      ],
    );
  }
}

class _PhotoPerson extends StatelessWidget {
  const _PhotoPerson({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.92),
            ),
          ),
          Positioned(
            top: 18,
            child: Container(
              width: 30,
              height: height - 18,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.72),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                  bottom: Radius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniClubCrest extends StatelessWidget {
  const _MiniClubCrest({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: CatchElevation.card,
      ),
      child: Icon(CatchIcons.wbSunnyOutlined, color: Colors.white, size: 19),
    );
  }
}

class _PhotoMemberSeal extends StatelessWidget {
  const _PhotoMemberSeal({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.surface.withValues(alpha: 0.9),
        border: Border.all(color: t.accent.withValues(alpha: 0.48), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label.replaceFirst(' ', '\n'),
        textAlign: TextAlign.center,
        style: CatchTextStyles.labelM(
          context,
          color: const Color(0xFF244646),
        ).copyWith(height: 1.05),
      ),
    );
  }
}

class _ClubCrest extends StatelessWidget {
  const _ClubCrest({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: CatchElevation.card,
      ),
      child: Icon(CatchIcons.wbSunnyOutlined, color: Colors.white, size: 34),
    );
  }
}

class _CircularSeal extends StatelessWidget {
  const _CircularSeal({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: t.accent.withValues(alpha: 0.42), width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: CatchTextStyles.labelM(context, color: t.accent),
      ),
    );
  }
}

class _PhotoClubHostLine extends StatelessWidget {
  const _PhotoClubHostLine({required this.club, required this.hostLabel});

  final ExploreConceptClubData club;
  final String hostLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _HostInitials(
          firstColor: club.accentColor,
          secondColor: club.secondaryAccentColor,
          includeThird: true,
        ),
        gapW10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MonoLabel('HOSTED BY', color: t.ink3),
              gapH2,
              Text(
                hostLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.labelM(context, color: t.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HostInitials extends StatelessWidget {
  const _HostInitials({
    required this.firstColor,
    required this.secondColor,
    this.includeThird = false,
  });

  final Color firstColor;
  final Color secondColor;
  final bool includeThird;

  @override
  Widget build(BuildContext context) {
    final thirdColor = CatchTokens.of(context).gold;
    return SizedBox(
      width: includeThird ? 98 : 70,
      height: 42,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: firstColor,
            child: Text(
              'A',
              style: _serif(context, size: 20, color: Colors.white),
            ),
          ),
          Positioned(
            left: 28,
            child: CircleAvatar(
              radius: 21,
              backgroundColor: secondColor,
              child: Text(
                includeThird ? 'A' : 'I',
                style: _serif(context, size: 20, color: Colors.white),
              ),
            ),
          ),
          if (includeThird)
            Positioned(
              left: 56,
              child: CircleAvatar(
                radius: 21,
                backgroundColor: thirdColor,
                child: Text(
                  'I',
                  style: _serif(context, size: 20, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClubTagsActionRow extends StatelessWidget {
  const _ClubTagsActionRow({required this.club});

  final ExploreConceptClubData club;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final tag in club.tags) _PaperChip(label: tag),
              _PaperChip(label: club.scheduleLabel),
            ],
          ),
        ),
        const SizedBox(width: CatchSpacing.s4),
        _DarkPill(label: club.actionLabel, compact: true),
      ],
    );
  }
}

class _PaperChip extends StatelessWidget {
  const _PaperChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        border: Border.all(color: t.line2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.s2,
        ),
        child: Text(label, style: CatchTextStyles.mono(context, color: t.ink2)),
      ),
    );
  }
}

class _ClubRule extends StatelessWidget {
  const _ClubRule({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: DecoratedBox(decoration: BoxDecoration(color: color)),
    );
  }
}

class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.label, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.ink,
        borderRadius: BorderRadius.circular(CatchRadius.pill),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? CatchSpacing.s4 : CatchSpacing.s5,
          vertical: compact ? CatchSpacing.micro10 : CatchSpacing.s3,
        ),
        child: Text(
          label,
          style:
              (compact
                      ? CatchTextStyles.labelM(context, color: t.primaryInk)
                      : CatchTextStyles.labelL(context, color: t.primaryInk))
                  .copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _MonoLabel extends StatelessWidget {
  const _MonoLabel(this.label, {required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.ibmPlexMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.15,
        color: color,
      ),
    );
  }
}

TextStyle _serif(
  BuildContext context, {
  required double size,
  double height = 1.1,
  Color? color,
}) {
  return GoogleFonts.getFont(
    'Instrument Serif',
    fontSize: size,
    fontStyle: FontStyle.italic,
    height: height,
    letterSpacing: 0,
    color: color ?? CatchTokens.of(context).ink,
  );
}

class _TicketShapeClipper extends CustomClipper<Path> {
  const _TicketShapeClipper({
    required this.cornerRadius,
    required this.notchRadius,
    required this.notchDepth,
    required this.notchCenterY,
  }) : assert(notchDepth <= notchRadius);

  final double cornerRadius;
  final double notchRadius;
  final double notchDepth;
  final double notchCenterY;

  @override
  Path getClip(Size size) {
    final radius = math.min(cornerRadius, size.shortestSide / 2);
    final top = notchCenterY - notchRadius;
    final bottom = notchCenterY + notchRadius;
    const circleKappa = 0.5522847498;

    return Path()
      ..moveTo(radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, top)
      ..cubicTo(
        size.width - circleKappa * notchDepth,
        top,
        size.width - notchDepth,
        notchCenterY - circleKappa * notchRadius,
        size.width - notchDepth,
        notchCenterY,
      )
      ..cubicTo(
        size.width - notchDepth,
        notchCenterY + circleKappa * notchRadius,
        size.width - circleKappa * notchDepth,
        bottom,
        size.width,
        bottom,
      )
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, bottom)
      ..cubicTo(
        circleKappa * notchDepth,
        bottom,
        notchDepth,
        notchCenterY + circleKappa * notchRadius,
        notchDepth,
        notchCenterY,
      )
      ..cubicTo(
        notchDepth,
        notchCenterY - circleKappa * notchRadius,
        circleKappa * notchDepth,
        top,
        0,
        top,
      )
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _TicketShapeClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchRadius != notchRadius ||
        oldClipper.notchDepth != notchDepth ||
        oldClipper.notchCenterY != notchCenterY;
  }
}

class _TicketPerforationPainter extends CustomPainter {
  const _TicketPerforationPainter({required this.lineColor});

  final Color lineColor;

  static const _dashWidth = 5.0;
  static const _dashGap = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    var x = _ticketNotchRadius + CatchSpacing.s2;
    final lineEnd = size.width - _ticketNotchRadius - CatchSpacing.s2;
    while (x < lineEnd) {
      canvas.drawLine(Offset(x, y), Offset(x + _dashWidth, y), linePaint);
      x += _dashWidth + _dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _TicketPerforationPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}

class _ClockPainter extends CustomPainter {
  const _ClockPainter({
    required this.ring,
    required this.hand,
    required this.time,
  });

  final Color ring;
  final Color hand;
  final TimeOfDay time;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 2;
    final ringPaint = Paint()
      ..color = ring
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final handPaint = Paint()
      ..color = hand
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final minuteHandPaint = Paint()
      ..color = hand
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;
    final hourAngle =
        (((time.hour % 12) * 60 + time.minute) / 720) * math.pi * 2 -
        math.pi / 2;
    final minuteAngle = (time.minute / 60) * math.pi * 2 - math.pi / 2;
    Offset handOffset(double length, double angle) {
      return Offset(math.cos(angle) * length, math.sin(angle) * length);
    }

    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawLine(
      center,
      center + handOffset(radius * 0.52, hourAngle),
      handPaint,
    );
    canvas.drawLine(
      center,
      center + handOffset(radius * 0.78, minuteAngle),
      minuteHandPaint,
    );
    canvas.drawCircle(center, 2.2, Paint()..color = hand);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return oldDelegate.ring != ring ||
        oldDelegate.hand != hand ||
        oldDelegate.time != time;
  }
}

TimeOfDay _clockTimeFor(ExploreConceptEventData event) {
  return event.clockTime ?? _parseClockTimeLabel(event.timeLabel);
}

TimeOfDay _parseClockTimeLabel(String label) {
  final match = RegExp(
    r'^\s*(\d{1,2})(?::(\d{2}))?\s*([aApP][mM])?\s*$',
  ).firstMatch(label);
  if (match == null) return const TimeOfDay(hour: 12, minute: 0);

  var hour = int.tryParse(match.group(1) ?? '') ?? 12;
  final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
  final meridiem = match.group(3)?.toLowerCase();
  if (minute < 0 || minute > 59) return const TimeOfDay(hour: 12, minute: 0);

  if (meridiem == 'pm' && hour != 12) {
    hour += 12;
  } else if (meridiem == 'am' && hour == 12) {
    hour = 0;
  }
  if (hour < 0 || hour > 23) return const TimeOfDay(hour: 12, minute: 0);
  return TimeOfDay(hour: hour, minute: minute);
}
