import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/rich_share_card_sheet.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_invite_share_copy.dart';
import 'package:flutter/material.dart';

Future<void> showEventShareCardSheet(
  BuildContext context, {
  required Event event,
  required ExternalShareController share,
  String? inviteCode,
  String? inviteLinkId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => RichShareCardSheet(
      card: EventShareCard(event: event),
      share: share,
      fileName: 'catch-event-invite.png',
      buttonLabel: 'Share invite',
      footnote: 'Shares a visual invite with the event link.',
      subject: EventInviteShareCopy.subject(event),
      text: EventInviteShareCopy.eventDetailInviteText(
        event,
        inviteCode: inviteCode,
        inviteLinkId: inviteLinkId,
      ),
    ),
  );
}

class EventShareCard extends StatelessWidget {
  const EventShareCard({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(event.activityKind, context: context);
    final priceLabel = event.isFree
        ? 'Free'
        : EventFormatters.priceInPaise(
            event.priceInPaise,
            currencyCode: event.currency,
          );

    return AspectRatio(
      aspectRatio: CatchLayout.richShareCardAspectRatio,
      child: CatchSurface(
        backgroundColor: t.ink,
        borderColor: t.line2,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  EventActivityBackdrop(
                    visual: visual,
                    dense: true,
                    iconAlignment: Alignment.centerRight,
                    iconSize: CatchLayout.eventHeroBackdropIconSize,
                    iconOpacity: CatchOpacity.fallbackArtworkIcon,
                  ),
                  Positioned(
                    top: CatchSpacing.s5,
                    left: CatchSpacing.s5,
                    child: CatchSurface(
                      backgroundColor: t.primaryInk.withValues(
                        alpha: CatchOpacity.scrimFill,
                      ),
                      borderColor: visual.accent.withValues(
                        alpha: CatchOpacity.subtleBorder,
                      ),
                      radius: CatchRadius.pill,
                      padding: CatchInsets.compactLabelContent,
                      child: Text(
                        'CATCH INVITE',
                        style: CatchTextStyles.labelS(
                          context,
                          color: visual.accent,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: CatchSpacing.s5,
                    right: CatchSpacing.s5,
                    child: CatchIconTile(
                      icon: visual.icon,
                      iconColor: visual.accent,
                      backgroundColor: t.primaryInk.withValues(
                        alpha: CatchOpacity.scrimFill,
                      ),
                      borderColor: visual.accent.withValues(
                        alpha: CatchOpacity.subtleBorder,
                      ),
                      size: CatchLayout.richShareCardHeaderIconExtent,
                      iconSize: CatchIcon.md,
                      radius: CatchRadius.pill,
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
                        Text(
                          event.activitySummaryLabel.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.kicker(
                            context,
                            color: t.primaryInk.withValues(
                              alpha: CatchOpacity.onFillMuted,
                            ),
                          ),
                        ),
                        gapH8,
                        Text(
                          event.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.eventDisplay(
                            context,
                            size: 34,
                            height: 0.98,
                            color: t.primaryInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: ColoredBox(
                color: t.surface,
                child: Padding(
                  padding: CatchInsets.contentRelaxed,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EventShareInfoRow(
                        icon: CatchIcons.calendarTodayOutlined,
                        label: event.longDateLabel,
                        accent: visual.accent,
                      ),
                      gapH10,
                      _EventShareInfoRow(
                        icon: CatchIcons.clock,
                        label: event.timeRangeLabel,
                        accent: visual.accent,
                      ),
                      gapH10,
                      _EventShareInfoRow(
                        icon: CatchIcons.locationOnOutlined,
                        label: event.locationName,
                        accent: visual.accent,
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: CatchSpacing.micro6,
                        runSpacing: CatchSpacing.micro6,
                        children: [
                          _EventSharePill(label: priceLabel),
                          _EventSharePill(label: _spotsLabel(event)),
                        ],
                      ),
                      gapH14,
                      Row(
                        children: [
                          Text(
                            'CATCH',
                            style: CatchTextStyles.kicker(
                              context,
                              color: t.ink,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Curated singles event',
                            style: CatchTextStyles.labelS(
                              context,
                              color: t.ink2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventShareInfoRow extends StatelessWidget {
  const _EventShareInfoRow({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Icon(icon, size: CatchIcon.md, color: accent),
        gapW10,
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.labelM(context, color: t.ink),
          ),
        ),
      ],
    );
  }
}

class _EventSharePill extends StatelessWidget {
  const _EventSharePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      backgroundColor: t.primarySoft,
      borderColor: t.primary.withValues(alpha: CatchOpacity.subtleBorder),
      radius: CatchRadius.pill,
      padding: CatchInsets.compactLabelContent,
      child: Text(label, style: CatchTextStyles.labelS(context, color: t.ink)),
    );
  }
}

String _spotsLabel(Event event) {
  final spots = event.spotsRemaining;
  if (spots == 1) return '1 spot left';
  if (spots == 0) return 'Waitlist open';
  return '$spots spots left';
}
