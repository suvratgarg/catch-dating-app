import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet_grabber.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class BookingConflictEvent {
  const BookingConflictEvent({
    required this.title,
    required this.when,
    this.activityKind,
  });

  final String title;
  final String when;
  final ActivityKind? activityKind;
}

abstract final class BookingConflictSheetKeys {
  static const replaceExistingButton = ValueKey(
    'booking.conflict.replaceExisting',
  );
  static const keepBothButton = ValueKey('booking.conflict.keepBoth');
  static const keepExistingButton = ValueKey('booking.conflict.keepExisting');
}

class BookingConflictSheet extends StatelessWidget {
  const BookingConflictSheet({
    super.key,
    required this.existing,
    required this.incoming,
    this.onReplaceExisting,
    this.onKeepBoth,
    this.onKeepExisting,
  });

  final BookingConflictEvent existing;
  final BookingConflictEvent incoming;
  final VoidCallback? onReplaceExisting;
  final VoidCallback? onKeepBoth;
  final VoidCallback? onKeepExisting;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      container: true,
      label: context.l10n.eventsBookingConflictSheetLabelBookingTimeConflict,
      child: CatchSurface(
        backgroundColor: t.surface,
        borderColor: t.line,
        elevation: CatchSurfaceElevation.overlay,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(CatchRadius.heroCard),
        ),
        width: double.infinity,
        padding: CatchInsets.pageBody.copyWith(
          top: CatchSpacing.s3,
          bottom: CatchSpacing.s6,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CatchBottomSheetGrabber(),
              gapH16,
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: CatchLayout.eventDetailConflictMedallionExtent,
                  height: CatchLayout.eventDetailConflictMedallionExtent,
                  child: ColoredBox(
                    color: t.warning.withValues(
                      alpha: CatchOpacity.warningFill,
                    ),
                    child: Icon(
                      CatchIcons.warningAmberRounded,
                      color: t.warning,
                      size: CatchIcon.statusMedallion,
                    ),
                  ),
                ),
              ),
              gapH14,
              Text(
                context.l10n.eventsBookingConflictSheetTextThatSTheSame,
                style: CatchTextStyles.headlineS(context, color: t.ink),
              ),
              gapH8,
              Text(
                context.l10n.eventsBookingConflictSheetTextYouReAlreadyBooked,
                style: CatchTextStyles.proseM(context, color: t.ink2),
              ),
              gapH18,
              BookingConflictEventRow(
                tag: context
                    .l10n
                    .eventsBookingConflictSheetVisiblecopyAlreadyBooked,
                tagColor: t.ink3,
                event: existing,
              ),
              gapH10,
              BookingConflictEventRow(
                tag: context.l10n.eventsBookingConflictSheetVisiblecopyNew,
                tagColor: t.warning,
                event: incoming,
              ),
              gapH18,
              CatchButton(
                key: BookingConflictSheetKeys.replaceExistingButton,
                label: context
                    .l10n
                    .eventsBookingConflictSheetLabelCancelExistingBookThis,
                fullWidth: true,
                icon: Icon(CatchIcons.swapHorizRounded),
                onPressed: onReplaceExisting,
              ),
              gapH10,
              CatchButton(
                key: BookingConflictSheetKeys.keepBothButton,
                label: context.l10n.eventsBookingConflictSheetLabelKeepBoth,
                variant: CatchButtonVariant.secondary,
                fullWidth: true,
                onPressed: onKeepBoth,
              ),
              gapH4,
              CatchButton(
                key: BookingConflictSheetKeys.keepExistingButton,
                label: context
                    .l10n
                    .eventsBookingConflictSheetLabelKeepExistingOnly,
                variant: CatchButtonVariant.ghost,
                fullWidth: true,
                onPressed: onKeepExisting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingConflictEventRow extends StatelessWidget {
  const BookingConflictEventRow({
    super.key,
    required this.tag,
    required this.tagColor,
    required this.event,
  });

  final String tag;
  final Color tagColor;
  final BookingConflictEvent event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = event.activityKind == null
        ? null
        : eventActivityVisual(event.activityKind!, context: context);

    return Padding(
      padding: CatchInsets.bookingConflictContent,
      child: Row(
        children: [
          SizedBox(
            width: CatchLayout.eventDetailConflictEventGlyphExtent,
            height: CatchLayout.eventDetailConflictEventGlyphExtent,
            child: ColoredBox(
              color: visual?.accent ?? t.primarySoft,
              child: Icon(
                visual?.icon ?? CatchIcons.calendarTodayOutlined,
                color: visual == null ? t.ink2 : t.primaryInk,
                size: CatchIcon.md,
              ),
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tag.toUpperCase(),
                  style: CatchTextStyles.badge(context, color: tagColor),
                ),
                gapH2,
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.fieldRowTitle(context, color: t.ink),
                ),
                gapH2,
                Text(
                  event.when,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.mono(
                    context,
                    color: t.ink2,
                  ).copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
