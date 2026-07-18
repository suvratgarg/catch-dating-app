import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class EventSuccessStructureConfigEditor extends StatelessWidget {
  const EventSuccessStructureConfigEditor({
    super.key,
    required this.value,
    required this.targetAttendeeCount,
    required this.enabled,
    required this.onChanged,
    this.sectionTitle,
  });

  final EventSuccessStructureConfig value;
  final int targetAttendeeCount;
  final bool enabled;
  final ValueChanged<EventSuccessStructureConfig> onChanged;
  final String? sectionTitle;

  @override
  Widget build(BuildContext context) {
    final estimatedUnitCount = value.estimatedUnitCount(targetAttendeeCount);
    final supportsUnitCount = value.unitKind.supportsUnitCount;
    final autoUnitCountSummary = supportsUnitCount
        ? context.l10n
              .eventSuccessEventSuccessStructureConfigEditorTextAutoAboutEstimatedunitcountTolowercase(
                estimatedUnitCount: estimatedUnitCount,
                toLowerCase: value.unitKind.label.toLowerCase(),
                targetAttendeeCount: targetAttendeeCount,
              )
        : context
              .l10n
              .eventSuccessEventSuccessStructureConfigEditorTextOneSharedGroupFor;

    return CatchSection.fieldRows(
      title: sectionTitle,
      children: [
        CatchField.optionCards<EventSuccessUnitKind>(
          title: context
              .l10n
              .eventSuccessEventSuccessStructureConfigEditorTextGroupPeopleInto,
          values: EventSuccessUnitKind.values,
          itemTitle: (kind) => kind.label,
          itemDescription: (kind) => kind.setupHint,
          selected: value.unitKind,
          enabled: enabled,
          onChanged: enabled ? (kind) => onChanged(_withUnitKind(kind)) : null,
        ),
        if (value.unitKind != EventSuccessUnitKind.wholeGroup)
          CatchField.stepper(
            title: value.unitKind.peoplePerLabel,
            body: context.l10n
                .eventSuccessEventSuccessStructureConfigEditorDetailTargetSizeForEach(
                  singularLabel: value.unitKind.singularLabel,
                ),
            value: value.unitSize,
            min: 2,
            max: 12,
            formatter: (number) => context.l10n
                .eventSuccessEventSuccessStructureConfigEditorVisiblecopyTointPeople(
                  toInt: number.toInt(),
                ),
            decreaseSemanticLabel: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorSemanticDecreasePeoplePerUnit,
            increaseSemanticLabel: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorSemanticIncreasePeoplePerUnit,
            enabled: enabled,
            onChanged: enabled
                ? (number) =>
                      onChanged(value.copyWith(unitSize: number.toInt()))
                : null,
          ),
        if (supportsUnitCount)
          CatchField.optionCards<bool>(
            title: value.unitKind.countLabel,
            values: const [false, true],
            itemTitle: (fixed) => fixed
                ? context
                      .l10n
                      .eventSuccessEventSuccessStructureConfigEditorLabelFixed
                : context
                      .l10n
                      .eventSuccessEventSuccessStructureConfigEditorLabelAuto,
            itemDescription: (fixed) => fixed
                ? context
                      .l10n
                      .eventSuccessEventSuccessStructureConfigEditorDetailSetTheNumberYourselfOrLetCatchWorkItOutFromAttendance
                : autoUnitCountSummary,
            selected: value.unitCount != null,
            enabled: enabled,
            onChanged: enabled
                ? (fixed) => onChanged(
                    value.copyWith(
                      unitCount: fixed ? estimatedUnitCount : null,
                    ),
                  )
                : null,
          ),
        if (supportsUnitCount && value.unitCount != null)
          CatchField.stepper(
            title: value.unitKind.countLabel,
            body: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorDetailSetTheNumberYourselfOrLetCatchWorkItOutFromAttendance,
            value: value.unitCount ?? estimatedUnitCount,
            min: 1,
            max: 40,
            formatter: (number) => context.l10n
                .eventSuccessEventSuccessStructureConfigEditorVisiblecopyTointTolowercase(
                  toInt: number.toInt(),
                  toLowerCase: value.unitKind.label.toLowerCase(),
                ),
            decreaseSemanticLabel: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorSemanticDecreaseUnitCount,
            increaseSemanticLabel: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorSemanticIncreaseUnitCount,
            enabled: enabled,
            onChanged: enabled
                ? (number) =>
                      onChanged(value.copyWith(unitCount: number.toInt()))
                : null,
          ),
        if (value.unitKind != EventSuccessUnitKind.wholeGroup) ...[
          CatchField.choices<EventSuccessActivityAssignmentAttribute>(
            title: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorTitleSpreadPeopleOutBy,
            body: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorTextCatchUsesThisWhenItBuildsTheGroups,
            values: EventSuccessActivityAssignmentAttribute.values,
            itemLabel: (attribute) => attribute.balanceLabel,
            selected: value.balanceActivityAttributes.toSet(),
            multi: true,
            enabled: enabled,
            onSelectionChanged: enabled
                ? (selection) => onChanged(
                    value.copyWith(
                      balanceActivityAttributes: _orderedAttributes(selection),
                      clusterActivityAttributes: value.clusterActivityAttributes
                          .where((attribute) => !selection.contains(attribute))
                          .toList(growable: false),
                    ),
                  )
                : null,
          ),
          CatchField.choices<EventSuccessActivityAssignmentAttribute>(
            title: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorTitleKeepSimilarPeopleTogetherBy,
            body: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorTextCatchUsesThisWhenItBuildsTheGroups,
            values: EventSuccessActivityAssignmentAttribute.values,
            itemLabel: (attribute) => attribute.clusterLabel,
            selected: value.clusterActivityAttributes.toSet(),
            multi: true,
            enabled: enabled,
            onSelectionChanged: enabled
                ? (selection) => onChanged(
                    value.copyWith(
                      clusterActivityAttributes: _orderedAttributes(selection),
                      balanceActivityAttributes: value.balanceActivityAttributes
                          .where((attribute) => !selection.contains(attribute))
                          .toList(growable: false),
                    ),
                  )
                : null,
          ),
        ],
        if (value.rotates) ...[
          CatchField.choices<EventSuccessRotationRepeatStrategy>(
            title: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorTextMeetingTheSamePersonAgain,
            values: EventSuccessRotationRepeatStrategy.values,
            itemLabel: (strategy) => strategy.label,
            selected: {value.rotationRepeatStrategy},
            enabled: enabled,
            onSelectionChanged: enabled
                ? (selection) => onChanged(
                    value.copyWith(rotationRepeatStrategy: selection.single),
                  )
                : null,
          ),
          CatchField.stepper(
            title: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorLabelMaxTimesTheSamePairMeets,
            body: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorDetailOnlyUsedWhenThereAreMoreRoundsThanPeopleToMeet,
            value: value.maxPairMeetings,
            min: 1,
            max: 10,
            formatter: (number) => context.l10n
                .eventSuccessEventSuccessStructureConfigEditorVisiblecopyTointValue2(
                  toInt: number.toInt(),
                  value2: number.toInt() == 1 ? 'time' : 'times',
                ),
            decreaseSemanticLabel: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorSemanticDecreaseMeetingsPerPair,
            increaseSemanticLabel: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorSemanticIncreaseMeetingsPerPair,
            enabled: enabled,
            onChanged: enabled
                ? (number) =>
                      onChanged(value.copyWith(maxPairMeetings: number.toInt()))
                : null,
          ),
        ],
        if (!enabled)
          CatchField.read(
            title: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorTextStructureIsLockedOnce,
            icon: CatchIcons.lockOutlineRounded,
          ),
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

List<EventSuccessActivityAssignmentAttribute> _orderedAttributes(
  Set<EventSuccessActivityAssignmentAttribute> selected,
) => EventSuccessActivityAssignmentAttribute.values
    .where(selected.contains)
    .toList(growable: false);
