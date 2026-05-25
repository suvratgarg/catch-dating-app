import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:flutter/material.dart';

class WhenWhereCard extends StatelessWidget {
  const WhenWhereCard({super.key, required this.event, this.onLocationTap});

  final Event event;
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final start = event.startTime;
    final canOpenLocation =
        event.hasExactStartingPoint && onLocationTap != null;

    return CatchSurface(
      padding: const EdgeInsets.all(16),
      radius: CatchRadius.md,
      borderColor: t.line,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: t.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${start.day}',
                      style: CatchTextStyles.statCompact(
                        context,
                        color: t.primary,
                      ),
                    ),
                    Text(
                      EventFormatters.shortMonth(start).toUpperCase(),
                      style: CatchTextStyles.statusLabel(
                        context,
                        color: t.primary,
                      ),
                    ),
                  ],
                ),
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.timeRangeLabel,
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                    gapH2,
                    Text(
                      event.longDateLabel,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: t.line, height: 1),
          ),
          Semantics(
            button: canOpenLocation,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canOpenLocation ? onLocationTap : null,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    CatchIconTile(
                      icon: Icons.location_on_outlined,
                      iconColor: t.ink2,
                      backgroundColor: t.raised,
                      borderColor: t.line,
                      size: 44,
                      iconSize: 20,
                      radius: 10,
                    ),
                    gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.locationName,
                            style: CatchTextStyles.sectionTitle(context),
                          ),
                          if (event.locationNotes != null &&
                              event.locationNotes!.isNotEmpty) ...[
                            gapH2,
                            Text(
                              event.locationNotes!,
                              style: CatchTextStyles.supporting(
                                context,
                                color: t.ink2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (canOpenLocation)
                      Icon(
                        Icons.chevron_right_rounded,
                        color: t.ink3,
                        size: 20,
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
