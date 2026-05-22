import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:flutter/material.dart';

class EventSuccessStructureConfigEditor extends StatelessWidget {
  const EventSuccessStructureConfigEditor({
    super.key,
    required this.value,
    required this.targetAttendeeCount,
    required this.enabled,
    required this.onChanged,
    this.showRotationCadence = true,
    this.showRevealCountdown = true,
    this.revealCountdownLabel = 'Reveal countdown',
  });

  final EventSuccessStructureConfig value;
  final int targetAttendeeCount;
  final bool enabled;
  final ValueChanged<EventSuccessStructureConfig> onChanged;
  final bool showRotationCadence;
  final bool showRevealCountdown;
  final String revealCountdownLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final estimatedUnitCount = value.estimatedUnitCount(targetAttendeeCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CatchBadge(
              label: '${value.unitSize} per ${value.unitKind.singularLabel}',
              tone: CatchBadgeTone.neutral,
              icon: Icons.groups_2_outlined,
            ),
            CatchBadge(
              label:
                  '$estimatedUnitCount ${value.unitKind.label.toLowerCase()}',
              tone: CatchBadgeTone.neutral,
              icon: Icons.grid_view_rounded,
            ),
            if (showRotationCadence)
              CatchBadge(
                label: value.rotates
                    ? '${value.rotationIntervalMinutes} min rotations'
                    : 'No timed rotation',
                tone: value.rotates
                    ? CatchBadgeTone.live
                    : CatchBadgeTone.neutral,
                icon: value.rotates
                    ? Icons.sync_alt_rounded
                    : Icons.schedule_outlined,
              ),
            if (showRevealCountdown && value.revealCountdownSeconds > 0)
              CatchBadge(
                label: '${value.revealCountdownSeconds}s reveal',
                tone: CatchBadgeTone.neutral,
                icon: Icons.timer_outlined,
              ),
          ],
        ),
        gapH8,
        Text(value.unitKind.setupHint, style: CatchTextStyles.bodyS(context)),
        gapH12,
        Text('Flow type', style: CatchTextStyles.labelL(context)),
        gapH8,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            for (final kind in EventSuccessUnitKind.values)
              CatchChip(
                label: kind.label,
                active: value.unitKind == kind,
                enabled: enabled,
                onTap: enabled ? () => onChanged(_withUnitKind(kind)) : null,
              ),
          ],
        ),
        gapH12,
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumn = constraints.maxWidth >= 560;
            final itemWidth = twoColumn
                ? (constraints.maxWidth - CatchSpacing.s3) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: CatchSpacing.s3,
              runSpacing: CatchSpacing.s3,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _StructureNumberField(
                    label: value.unitKind.peoplePerLabel,
                    detail: value.unitKind == EventSuccessUnitKind.wholeGroup
                        ? 'Whole-group formats use the target attendance.'
                        : 'Target size for each ${value.unitKind.singularLabel}.',
                    child: CatchNumberStepper(
                      value: value.unitSize,
                      min: value.unitKind == EventSuccessUnitKind.wholeGroup
                          ? targetAttendeeCount
                          : 2,
                      max: value.unitKind == EventSuccessUnitKind.wholeGroup
                          ? targetAttendeeCount
                          : 12,
                      formatValue: (number) => '${number.toInt()} people',
                      enabled:
                          enabled &&
                          value.unitKind != EventSuccessUnitKind.wholeGroup,
                      onChanged: (number) =>
                          onChanged(value.copyWith(unitSize: number.toInt())),
                    ),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _StructureNumberField(
                    label: value.unitKind.countLabel,
                    detail: value.unitKind.supportsUnitCount
                        ? 'Set a host-owned count or let Catch estimate it from attendance.'
                        : 'Whole-group formats keep everyone in one shared flow.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: CatchSpacing.s2,
                          runSpacing: CatchSpacing.s2,
                          children: [
                            CatchChip(
                              label: 'Auto',
                              active: value.unitCount == null,
                              enabled:
                                  enabled && value.unitKind.supportsUnitCount,
                              onTap: enabled && value.unitKind.supportsUnitCount
                                  ? () => onChanged(
                                      value.copyWith(unitCount: null),
                                    )
                                  : null,
                            ),
                            CatchChip(
                              label: 'Fixed',
                              active: value.unitCount != null,
                              enabled:
                                  enabled && value.unitKind.supportsUnitCount,
                              onTap: enabled && value.unitKind.supportsUnitCount
                                  ? () => onChanged(
                                      value.copyWith(
                                        unitCount: estimatedUnitCount,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                        gapH8,
                        if (value.unitCount == null)
                          Text(
                            value.unitKind.supportsUnitCount
                                ? 'Auto: about $estimatedUnitCount ${value.unitKind.label.toLowerCase()} from $targetAttendeeCount target attendees.'
                                : 'One shared group for the full event.',
                            style: CatchTextStyles.bodyS(
                              context,
                              color: t.ink2,
                            ),
                          )
                        else
                          CatchNumberStepper(
                            value: value.unitCount ?? estimatedUnitCount,
                            min: 1,
                            max: 40,
                            formatValue: (number) =>
                                '${number.toInt()} ${value.unitKind.label.toLowerCase()}',
                            enabled:
                                enabled &&
                                value.unitKind.supportsUnitCount &&
                                value.unitCount != null,
                            onChanged: (number) => onChanged(
                              value.copyWith(unitCount: number.toInt()),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (showRotationCadence) ...[
          gapH12,
          Text('Rotation cadence', style: CatchTextStyles.labelL(context)),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final interval in const <int?>[null, 10, 15, 20, 30])
                CatchChip(
                  label: interval == null
                      ? 'No timed rotation'
                      : '$interval min',
                  active: value.rotationIntervalMinutes == interval,
                  enabled: enabled,
                  onTap: enabled
                      ? () => onChanged(
                          value.copyWith(rotationIntervalMinutes: interval),
                        )
                      : null,
                ),
            ],
          ),
        ],
        if (showRevealCountdown) ...[
          gapH12,
          Text(revealCountdownLabel, style: CatchTextStyles.labelL(context)),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final seconds in const [0, 5, 10, 15])
                CatchChip(
                  label: seconds == 0 ? 'Off' : '${seconds}s',
                  active: value.revealCountdownSeconds == seconds,
                  enabled: enabled,
                  onTap: enabled
                      ? () => onChanged(
                          value.copyWith(revealCountdownSeconds: seconds),
                        )
                      : null,
                ),
            ],
          ),
        ],
        if (!enabled) ...[
          gapH8,
          Text(
            'Structure is locked once attendance or waitlist activity exists.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ],
      ],
    );
  }

  EventSuccessStructureConfig _withUnitKind(EventSuccessUnitKind kind) {
    return switch (kind) {
      EventSuccessUnitKind.wholeGroup => value.copyWith(
        unitKind: kind,
        unitSize: targetAttendeeCount,
        unitCount: 1,
        rotationIntervalMinutes: null,
      ),
      EventSuccessUnitKind.pods => value.copyWith(
        unitKind: kind,
        unitSize: value.unitSize.clamp(3, 8).toInt(),
        unitCount: null,
        rotationIntervalMinutes: null,
      ),
      EventSuccessUnitKind.pairs => value.copyWith(
        unitKind: kind,
        unitSize: 2,
        unitCount: null,
        rotationIntervalMinutes: value.rotationIntervalMinutes ?? 15,
      ),
      EventSuccessUnitKind.teams => value.copyWith(
        unitKind: kind,
        unitSize: value.unitSize.clamp(3, 8).toInt(),
        unitCount: null,
        rotationIntervalMinutes: value.rotationIntervalMinutes,
      ),
      EventSuccessUnitKind.tables => value.copyWith(
        unitKind: kind,
        unitSize: value.unitSize.clamp(3, 8).toInt(),
        unitCount: value.unitCount,
        rotationIntervalMinutes: value.rotationIntervalMinutes ?? 30,
      ),
    };
  }
}

class _StructureNumberField extends StatelessWidget {
  const _StructureNumberField({
    required this.label,
    required this.detail,
    required this.child,
  });

  final String label;
  final String detail;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CatchTextStyles.labelL(context)),
        gapH4,
        Text(detail, style: CatchTextStyles.bodyS(context, color: t.ink2)),
        gapH8,
        child,
      ],
    );
  }
}
