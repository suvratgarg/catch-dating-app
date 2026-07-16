import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
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
  });

  final EventSuccessStructureConfig value;
  final int targetAttendeeCount;
  final bool enabled;
  final ValueChanged<EventSuccessStructureConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
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

    return CatchSectionList(
      gap: CatchGaps.formField,
      children: [
        CatchSection.plain(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CatchBadge(
                    label: context.l10n
                        .eventSuccessEventSuccessStructureConfigEditorLabelUnitsizePerSingularlabel(
                          unitSize: value.unitSize,
                          singularLabel: value.unitKind.singularLabel,
                        ),
                    icon: CatchIcons.groups2Outlined,
                  ),
                  CatchBadge(
                    label: context.l10n
                        .eventSuccessEventSuccessStructureConfigEditorLabelEstimatedunitcountTolowercase(
                          estimatedUnitCount: estimatedUnitCount,
                          toLowerCase: value.unitKind.label.toLowerCase(),
                        ),
                    icon: CatchIcons.gridViewRounded,
                  ),
                ],
              ),
              gapH8,
              Text(
                value.unitKind.setupHint,
                style: CatchTextStyles.supporting(context),
              ),
            ],
          ),
        ),
        CatchField.choices<EventSuccessUnitKind>(
          title: context
              .l10n
              .eventSuccessEventSuccessStructureConfigEditorTextFlowType,
          body: value.unitKind.setupHint,
          values: EventSuccessUnitKind.values,
          itemLabel: (kind) => kind.label,
          selected: {value.unitKind},
          enabled: enabled,
          initiallyOpen: true,
          onSelectionChanged: enabled
              ? (selection) => onChanged(_withUnitKind(selection.single))
              : null,
        ),
        CatchField.stepper(
          title: value.unitKind.peoplePerLabel,
          body: value.unitKind == EventSuccessUnitKind.wholeGroup
              ? context
                    .l10n
                    .eventSuccessEventSuccessStructureConfigEditorDetailWholeGroupFormatsUse
              : context.l10n
                    .eventSuccessEventSuccessStructureConfigEditorDetailTargetSizeForEach(
                      singularLabel: value.unitKind.singularLabel,
                    ),
          value: value.unitSize,
          min: value.unitKind == EventSuccessUnitKind.wholeGroup
              ? targetAttendeeCount
              : 2,
          max: value.unitKind == EventSuccessUnitKind.wholeGroup
              ? targetAttendeeCount
              : 12,
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
          enabled: enabled && value.unitKind != EventSuccessUnitKind.wholeGroup,
          initiallyOpen: true,
          onChanged:
              enabled && value.unitKind != EventSuccessUnitKind.wholeGroup
              ? (number) => onChanged(value.copyWith(unitSize: number.toInt()))
              : null,
        ),
        CatchField.choices<bool>(
          title: value.unitKind.countLabel,
          body: value.unitCount == null
              ? autoUnitCountSummary
              : context
                    .l10n
                    .eventSuccessEventSuccessStructureConfigEditorDetailSetAHostOwned,
          values: const [false, true],
          itemLabel: (fixed) => fixed
              ? context
                    .l10n
                    .eventSuccessEventSuccessStructureConfigEditorLabelFixed
              : context
                    .l10n
                    .eventSuccessEventSuccessStructureConfigEditorLabelAuto,
          selected: {value.unitCount != null},
          enabled: enabled && supportsUnitCount,
          initiallyOpen: true,
          onSelectionChanged: enabled && supportsUnitCount
              ? (selection) => onChanged(
                  value.copyWith(
                    unitCount: selection.single ? estimatedUnitCount : null,
                  ),
                )
              : null,
        ),
        if (value.unitCount != null)
          CatchField.stepper(
            title: value.unitKind.countLabel,
            body: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorDetailSetAHostOwned,
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
            enabled: enabled && supportsUnitCount,
            initiallyOpen: true,
            onChanged: enabled && supportsUnitCount
                ? (number) =>
                      onChanged(value.copyWith(unitCount: number.toInt()))
                : null,
          ),
        if (value.unitKind != EventSuccessUnitKind.wholeGroup) ...[
          CatchField.choices<EventSuccessActivityAssignmentAttribute>(
            title: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorTitleBalanceAcrossUnits,
            body: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorTextAssignmentGoals,
            values: EventSuccessActivityAssignmentAttribute.values,
            itemLabel: (attribute) => attribute.balanceLabel,
            selected: value.balanceActivityAttributes.toSet(),
            multi: true,
            enabled: enabled,
            initiallyOpen: true,
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
                .eventSuccessEventSuccessStructureConfigEditorTitleClusterSimilarPeople,
            body: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorTextAssignmentGoals,
            values: EventSuccessActivityAssignmentAttribute.values,
            itemLabel: (attribute) => attribute.clusterLabel,
            selected: value.clusterActivityAttributes.toSet(),
            multi: true,
            enabled: enabled,
            initiallyOpen: true,
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
                .eventSuccessEventSuccessStructureConfigEditorTextRepeatPolicy,
            values: EventSuccessRotationRepeatStrategy.values,
            itemLabel: (strategy) => strategy.label,
            selected: {value.rotationRepeatStrategy},
            enabled: enabled,
            initiallyOpen: true,
            onSelectionChanged: enabled
                ? (selection) => onChanged(
                    value.copyWith(rotationRepeatStrategy: selection.single),
                  )
                : null,
          ),
          CatchField.stepper(
            title: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorLabelMaxMeetingsPerPair,
            body: context
                .l10n
                .eventSuccessEventSuccessStructureConfigEditorDetailCapsRepeatPairingsWhen,
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
            initiallyOpen: true,
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
            iconColor: t.ink2,
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
