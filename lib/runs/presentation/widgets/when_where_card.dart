import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';

class WhenWhereCard extends StatelessWidget {
  const WhenWhereCard({super.key, required this.run});

  final Run run;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final start = run.startTime;

    return CatchSurface(
      padding: const EdgeInsets.all(16),
      tone: CatchSurfaceTone.raised,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: t.primary,
                        height: 1,
                      ),
                    ),
                    Text(
                      RunFormatters.shortMonth(start).toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: t.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      run.timeRangeLabel,
                      style: CatchTextStyles.titleM(context),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      run.longDateLabel,
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: t.raised,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: t.line),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: t.ink2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      run.meetingPoint,
                      style: CatchTextStyles.titleM(context),
                    ),
                    if (run.locationDetails != null &&
                        run.locationDetails!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        run.locationDetails!,
                        style: CatchTextStyles.bodyS(context, color: t.ink2),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: t.ink3, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
