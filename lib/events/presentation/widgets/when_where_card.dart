import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:flutter/material.dart';

class WhenWhereCard extends StatelessWidget {
  const WhenWhereCard({
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
    final t = CatchTokens.of(context);
    final start = event.startTime;
    final canOpenLocation =
        event.hasExactStartingPoint && onLocationTap != null;
    final style = surfaceStyle;

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      radius: CatchRadius.md,
      backgroundColor: style?.surfaceBackground,
      borderColor: style?.borderColor ?? t.line,
      child: Column(
        children: [
          Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: CatchLayout.eventInfoTileExtent,
                  minHeight: CatchLayout.eventInfoTileExtent,
                ),
                child: CatchSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CatchSpacing.micro6,
                    vertical: CatchSpacing.s1,
                  ),
                  radius: CatchRadius.infoTile,
                  backgroundColor: style?.primarySoftColor ?? t.primarySoft,
                  borderWidth: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${start.day}',
                        style: CatchTextStyles.statCompact(
                          context,
                          color: style?.primaryColor ?? t.primary,
                        ),
                      ),
                      Text(
                        EventFormatters.shortMonth(start).toUpperCase(),
                        style: CatchTextStyles.statusLabel(
                          context,
                          color: style?.primaryColor ?? t.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.timeRangeLabel,
                      style: CatchTextStyles.sectionTitle(
                        context,
                        color: style?.headingColor,
                      ),
                    ),
                    gapH2,
                    Text(
                      event.longDateLabel,
                      style: CatchTextStyles.supporting(
                        context,
                        color: style?.bodyColor ?? t.ink2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s3),
            child: Divider(color: style?.dividerColor ?? t.line, height: 1),
          ),
          Semantics(
            button: canOpenLocation,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canOpenLocation ? onLocationTap : null,
                borderRadius: BorderRadius.circular(
                  CatchRadius.interactiveTile,
                ),
                child: Row(
                  children: [
                    CatchIconTile(
                      icon: CatchIcons.locationOnOutlined,
                      iconColor: style?.bodyColor ?? t.ink2,
                      backgroundColor: style?.raisedBackground ?? t.raised,
                      borderColor: style?.borderColor ?? t.line,
                      size: CatchLayout.eventInfoTileExtent,
                      iconSize: CatchIcon.control,
                      radius: CatchRadius.infoTile,
                    ),
                    gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.locationName,
                            style: CatchTextStyles.sectionTitle(
                              context,
                              color: style?.headingColor,
                            ),
                          ),
                          if (event.locationNotes != null &&
                              event.locationNotes!.isNotEmpty) ...[
                            gapH2,
                            Text(
                              event.locationNotes!,
                              style: CatchTextStyles.supporting(
                                context,
                                color: style?.bodyColor ?? t.ink2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (canOpenLocation)
                      Icon(
                        CatchIcons.chevronRightRounded,
                        color: style?.mutedColor ?? t.ink3,
                        size: CatchIcon.control,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
