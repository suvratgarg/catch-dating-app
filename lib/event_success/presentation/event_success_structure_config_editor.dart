import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:flutter/material.dart';

class EventSuccessStructureConfigEditor extends StatelessWidget {
  const EventSuccessStructureConfigEditor({
    super.key,
    required this.value,
    required this.targetAttendeeCount,
    required this.enabled,
    required this.onChanged,
  });

  final EventSuccessStructureConfig value;
  final int targetAttendeeCount;
  final bool enabled;
  final ValueChanged<EventSuccessStructureConfig> onChanged;

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
              icon: CatchIcons.groups2Outlined,
            ),
            CatchBadge(
              label:
                  '$estimatedUnitCount ${value.unitKind.label.toLowerCase()}',
              icon: CatchIcons.gridViewRounded,
            ),
          ],
        ),
        gapH8,
        Text(
          value.unitKind.setupHint,
          style: CatchTextStyles.supporting(context),
        ),
        gapH12,
        Text('Flow type', style: CatchTextStyles.labelL(context)),
        gapH8,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            for (final kind in EventSuccessUnitKind.values)
              CatchSelectChip(
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
            final twoColumn =
                constraints.maxWidth >=
                ComponentBreakpoints.eventSuccessConfigTwoColumnBreakpoint;
            final itemWidth = twoColumn
                ? (constraints.maxWidth - CatchSpacing.s3) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: CatchSpacing.s3,
              runSpacing: CatchSpacing.s3,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: StructureNumberField(
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
                  child: StructureNumberField(
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
                            CatchSelectChip(
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
                            CatchSelectChip(
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
                            style: CatchTextStyles.supporting(
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
        if (value.unitKind != EventSuccessUnitKind.wholeGroup) ...[
          gapH12,
          Text('Assignment goals', style: CatchTextStyles.labelL(context)),
          gapH8,
          ActivityAttributeGoalChips(
            title: 'Balance across units',
            attributes: value.balanceActivityAttributes,
            labelFor: (attribute) => attribute.balanceLabel,
            enabled: enabled,
            onToggle: (attribute) => onChanged(
              value.copyWith(
                balanceActivityAttributes: _toggleAttribute(
                  value.balanceActivityAttributes,
                  attribute,
                ),
                clusterActivityAttributes: _removeAttribute(
                  value.clusterActivityAttributes,
                  attribute,
                ),
              ),
            ),
          ),
          gapH8,
          ActivityAttributeGoalChips(
            title: 'Cluster similar people',
            attributes: value.clusterActivityAttributes,
            labelFor: (attribute) => attribute.clusterLabel,
            enabled: enabled,
            onToggle: (attribute) => onChanged(
              value.copyWith(
                clusterActivityAttributes: _toggleAttribute(
                  value.clusterActivityAttributes,
                  attribute,
                ),
                balanceActivityAttributes: _removeAttribute(
                  value.balanceActivityAttributes,
                  attribute,
                ),
              ),
            ),
          ),
        ],
        if (value.rotates) ...[
          gapH12,
          Text('Repeat policy', style: CatchTextStyles.labelL(context)),
          gapH8,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final strategy in EventSuccessRotationRepeatStrategy.values)
                CatchSelectChip(
                  label: strategy.label,
                  active: value.rotationRepeatStrategy == strategy,
                  enabled: enabled,
                  onTap: enabled
                      ? () => onChanged(
                          value.copyWith(rotationRepeatStrategy: strategy),
                        )
                      : null,
                ),
            ],
          ),
          gapH8,
          StructureNumberField(
            label: 'Max meetings per pair',
            detail: 'Caps repeat pairings when the event has extra rounds.',
            child: CatchNumberStepper(
              value: value.maxPairMeetings,
              min: 1,
              max: 10,
              formatValue: (number) =>
                  '${number.toInt()} ${number.toInt() == 1 ? 'time' : 'times'}',
              enabled: enabled,
              onChanged: (number) =>
                  onChanged(value.copyWith(maxPairMeetings: number.toInt())),
            ),
          ),
        ],
        if (!enabled) ...[
          gapH8,
          Text(
            'Structure is locked once attendance or waitlist activity exists.',
            style: CatchTextStyles.supporting(context, color: t.ink2),
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
        balanceActivityAttributes: const [],
        clusterActivityAttributes: const [],
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

class ActivityAttributeGoalChips extends StatelessWidget {
  const ActivityAttributeGoalChips({
    required this.title,
    required this.attributes,
    required this.labelFor,
    required this.enabled,
    required this.onToggle,
  });

  final String title;
  final List<EventSuccessActivityAssignmentAttribute> attributes;
  final String Function(EventSuccessActivityAssignmentAttribute attribute)
  labelFor;
  final bool enabled;
  final ValueChanged<EventSuccessActivityAssignmentAttribute> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CatchTextStyles.supporting(context)),
        gapH4,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            for (final attribute
                in EventSuccessActivityAssignmentAttribute.values)
              CatchSelectChip(
                label: labelFor(attribute),
                active: attributes.contains(attribute),
                enabled: enabled,
                onTap: enabled ? () => onToggle(attribute) : null,
              ),
          ],
        ),
      ],
    );
  }
}

class StructureNumberField extends StatelessWidget {
  const StructureNumberField({
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
        Text(detail, style: CatchTextStyles.supporting(context, color: t.ink2)),
        gapH8,
        child,
      ],
    );
  }
}

List<EventSuccessActivityAssignmentAttribute> _toggleAttribute(
  List<EventSuccessActivityAssignmentAttribute> attributes,
  EventSuccessActivityAssignmentAttribute attribute,
) {
  if (attributes.contains(attribute)) {
    return _removeAttribute(attributes, attribute);
  }
  return List.unmodifiable([...attributes, attribute]);
}

List<EventSuccessActivityAssignmentAttribute> _removeAttribute(
  List<EventSuccessActivityAssignmentAttribute> attributes,
  EventSuccessActivityAssignmentAttribute attribute,
) => List.unmodifiable(attributes.where((item) => item != attribute));
