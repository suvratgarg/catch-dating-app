import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_hype_avatar_stack.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_atoms.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

class EventHeroTile extends StatelessWidget {
  const EventHeroTile({
    super.key,
    required this.data,
    required this.viewerInterestedInGenders,
    this.onTap,
    this.surfaceKey,
  });

  final EventTileData data;
  final List<Gender> viewerInterestedInGenders;
  final VoidCallback? onTap;
  final Key? surfaceKey;

  static String countdown(DateTime startTime) {
    final diff = startTime.difference(DateTime.now());
    if (diff.inDays >= 1) return 'IN ${diff.inDays}D';
    if (diff.inHours >= 1) return 'IN ${diff.inHours}H';
    return 'STARTING SOON';
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CatchSurface(
      key: surfaceKey,
      padding: EdgeInsets.zero,
      backgroundColor: t.surface,
      borderColor: t.line2,
      radius: 22,
      clipBehavior: Clip.antiAlias,
      onTap: onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    t.primarySoft.withValues(alpha: isDark ? 0.36 : 0.62),
                    t.surface.withValues(alpha: isDark ? 0.94 : 0.98),
                    t.raised.withValues(alpha: isDark ? 0.74 : 0.88),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -32,
            top: -40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.primary.withValues(alpha: isDark ? 0.13 : 0.08),
              ),
              child: const SizedBox.square(dimension: 150),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(CatchSpacing.micro18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _NextEventStatusPill(
                        label: countdown(data.event.startTime),
                      ),
                    ),
                    if (data.positionLabel != null) ...[
                      gapW8,
                      EventTileStatusBadge(
                        status: data.status,
                        label: data.positionLabel,
                      ),
                    ],
                  ],
                ),
                gapH14,
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.displayM(context, color: t.ink),
                ),
                if (data.clubName != null) ...[
                  gapH6,
                  Text(
                    data.clubName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.labelM(context, color: t.ink2),
                  ),
                ],
                gapH12,
                Wrap(
                  spacing: CatchSpacing.s3,
                  runSpacing: CatchSpacing.s1,
                  children: [
                    _EventMetaChip(
                      icon: CatchIcons.accessTimeRounded,
                      label: '${data.dateLabel} · ${data.timeRangeLabel}',
                    ),
                    _EventMetaChip(
                      icon: CatchIcons.locationOnOutlined,
                      label: data.meetingPoint,
                    ),
                    _EventMetaChip(
                      icon: CatchIcons.routeOutlined,
                      label: data.activitySummaryLabel,
                    ),
                  ],
                ),
                gapH16,
                _ConfirmedRow(
                  data: data,
                  viewerInterestedInGenders: viewerInterestedInGenders,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextEventStatusPill extends StatelessWidget {
  const _NextEventStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      radius: CatchRadius.pill,
      backgroundColor: t.primarySoft.withValues(alpha: 0.72),
      borderColor: t.primary.withValues(alpha: 0.18),
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.s1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchStatusDot(color: t.primary),
          gapW8,
          Flexible(
            child: Text(
              'NEXT EVENT · $label',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.statusLabel(context, color: t.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventMetaChip extends StatelessWidget {
  const _EventMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: t.ink3),
          gapW4,
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmedRow extends StatelessWidget {
  const _ConfirmedRow({
    required this.data,
    required this.viewerInterestedInGenders,
  });

  final EventTileData data;
  final List<Gender> viewerInterestedInGenders;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final signedUpCount = data.event.signedUpCount;

    return Row(
      children: [
        if (signedUpCount > 0) ...[
          EventHypeAvatarStack(
            eventId: data.eventId,
            totalCount: signedUpCount,
            viewerInterestedInGenders: viewerInterestedInGenders,
            size: 32,
            limit: 4,
            obscured: true,
            showOverflowCount: false,
          ),
          gapW10,
        ],
        Flexible(
          child: Text(
            '$signedUpCount attendee${signedUpCount == 1 ? '' : 's'} confirmed',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.bodyLead(context, color: t.ink2),
          ),
        ),
      ],
    );
  }
}
