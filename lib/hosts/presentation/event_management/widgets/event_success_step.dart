import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/event_success.dart'
    show
        EventSuccessController,
        EventSuccessDefaultsPanel,
        eventSuccessControllerProvider;
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventSuccessStep extends ConsumerWidget {
  const EventSuccessStep({
    super.key,
    required this.organizerId,
    required this.activityKind,
    required this.eventSuccessDefaults,
    required this.targetAttendeeCount,
    required this.onEventSuccessDefaultsChanged,
    this.eventFormat,
  });

  final String organizerId;
  final ActivityKind activityKind;
  final EventFormatSnapshot? eventFormat;
  final EventSuccessDefaults eventSuccessDefaults;
  final int targetAttendeeCount;
  final ValueChanged<EventSuccessDefaults> onEventSuccessDefaultsChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final layoutsAsync = ref.watch(
      watchOrganizerEventSuccessLayoutsProvider(organizerId),
    );
    final layoutMutation = ref.watch(
      EventSuccessController.upsertLayoutMutation,
    );
    Future<EventSuccessLayout> saveLayout(EventSuccessLayout layout) =>
        EventSuccessController.upsertLayoutMutation.run(
          ref,
          (tx) => tx
              .get(eventSuccessControllerProvider.notifier)
              .upsertLayout(organizerId: organizerId, layout: layout),
        );
    final layouts = layoutsAsync.asData?.value ?? const <EventSuccessLayout>[];
    final usesWholeGroup =
        eventSuccessDefaults.structureConfig.unitKind ==
        EventSuccessUnitKind.wholeGroup;

    return ListView(
      padding: CatchInsets.formStepBodyRelaxedWithBottomActions,
      children: [
        CatchSectionList(
          emptyStateOmitted: true,
          children: [
            CatchSection.plain(
              child: Text(
                context.l10n.hostsEventSuccessStepTextPrepareTheHostGuide,
                style: CatchTextStyles.supporting(context, color: t.primary),
              ),
            ),
            EventSuccessDefaultsPanel(
              defaults: eventSuccessDefaults,
              activityKind: activityKind,
              eventFormat: eventFormat,
              targetAttendeeCount: targetAttendeeCount,
              onChanged: (update) =>
                  onEventSuccessDefaultsChanged(update(eventSuccessDefaults)),
              title: context.l10n.hostsEventSuccessStepTitleLiveEventGuide,
              subtitle:
                  context.l10n.hostsEventSuccessStepSubtitleSaveASimplePlan,
            ),
            if (eventSuccessDefaults.enabled && !usesWholeGroup)
              CatchSection.fieldRows(
                title: context.l10n.hostsEventSuccessStepRoomLayoutTitle,
                footer: Text(
                  context.l10n.hostsEventSuccessStepRoomLayoutSubtitle,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                children: [
                  if (layoutsAsync.hasError)
                    CatchErrorBanner.fromError(
                      layoutsAsync.error!,
                      context: AppErrorContext.event,
                    ),
                  for (final layout in layouts)
                    CatchField.nav(
                      title: layout.label,
                      body: context.l10n
                          .hostsEventSuccessStepRoomLayoutUnitCount(
                            count: layout.units.length,
                          ),
                      valueText:
                          eventSuccessDefaults.layoutId == layout.layoutId
                          ? context.l10n.hostsEventSuccessStepRoomLayoutSelected
                          : null,
                      showChevron: false,
                      onTap: () => onEventSuccessDefaultsChanged(
                        eventSuccessDefaults.copyWith(
                          layoutId: layout.layoutId,
                        ),
                      ),
                    ),
                  CatchField.add(
                    title: context.l10n.hostsEventSuccessStepRoomLayoutCreate,
                    onTap: layoutMutation.isPending
                        ? null
                        : () => _createLayout(context, saveLayout),
                  ),
                  if (layoutMutation.hasError)
                    CatchErrorBanner.fromError(
                      (layoutMutation as MutationError).error,
                      context: AppErrorContext.event,
                    ),
                ],
              ),
            if (eventSuccessDefaults.enabled && usesWholeGroup)
              CatchSection.fieldRows(
                children: [
                  CatchField.content(
                    title: context
                        .l10n
                        .hostsEventSuccessStepRoomLayoutWholeGroupTitle,
                    body: context
                        .l10n
                        .hostsEventSuccessStepRoomLayoutWholeGroupBody,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _createLayout(
    BuildContext context,
    Future<EventSuccessLayout> Function(EventSuccessLayout layout) saveLayout,
  ) async {
    final draft = await showCatchBottomSheet<EventSuccessLayout>(
      context: context,
      builder: (context) => const _EventSuccessLayoutAuthorSheet(),
    );
    if (draft == null || !context.mounted) return;
    final saved = await saveLayout(draft);
    if (!context.mounted) return;
    onEventSuccessDefaultsChanged(
      eventSuccessDefaults.copyWith(layoutId: saved.layoutId),
    );
  }
}

class _EventSuccessLayoutAuthorSheet extends StatefulWidget {
  const _EventSuccessLayoutAuthorSheet();

  @override
  State<_EventSuccessLayoutAuthorSheet> createState() =>
      _EventSuccessLayoutAuthorSheetState();
}

class _EventSuccessLayoutAuthorSheetState
    extends State<_EventSuccessLayoutAuthorSheet> {
  final _labelController = TextEditingController();
  var _shape = EventSuccessLayoutShape.round;
  var _unitCount = 6;
  var _unitCapacity = 4;
  var _columnCount = 3;
  String? _labelError;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unitListContract =
        CatchContractConstraints.upsertEventSuccessLayoutCallablePayloadUnits;
    final capacityContract = CatchContractConstraints
        .upsertEventSuccessLayoutCallablePayloadUnitsItemsCapacity;
    final gridContract = CatchContractConstraints
        .upsertEventSuccessLayoutCallablePayloadUnitsItemsGridX;
    final minUnits = unitListContract.minItems ?? 1;
    final maxUnits = unitListContract.maxItems ?? 200;
    final minCapacity = capacityContract.minimum ?? 1;
    final maxCapacity = capacityContract.maximum ?? 1000;
    final maxColumns = (gridContract.maximum ?? 199) + 1;
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsEventSuccessStepRoomLayoutAuthorTitle,
      subtitle: context.l10n.hostsEventSuccessStepRoomLayoutAuthorSubtitle,
      keyboardSafe: true,
      child: SingleChildScrollView(
        child: CatchSectionList(
          emptyStateOmitted: true,
          children: [
            CatchSection.fieldRows(
              children: [
                CatchField.input(
                  title: context.l10n.hostsEventSuccessStepRoomLayoutName,
                  contract: CatchContractConstraints
                      .upsertEventSuccessLayoutCallablePayloadLabel,
                  controller: _labelController,
                  error: _labelError,
                  onChanged: (_) {
                    if (_labelError != null) {
                      setState(() => _labelError = null);
                    }
                  },
                ),
                CatchField.select<EventSuccessLayoutShape>(
                  title: context.l10n.hostsEventSuccessStepRoomLayoutShape,
                  contract: CatchContractConstraints
                      .upsertEventSuccessLayoutCallablePayloadUnitsItemsShape,
                  contractValue: (shape) => shape.wireName,
                  values: EventSuccessLayoutShape.values,
                  itemLabel: (shape) => _shapeLabel(context, shape),
                  value: _shape,
                  onChanged: (shape) {
                    if (shape != null) setState(() => _shape = shape);
                  },
                ),
                CatchField.stepper(
                  title: context.l10n.hostsEventSuccessStepRoomLayoutUnits,
                  contract: unitListContract,
                  value: _unitCount,
                  min: minUnits,
                  max: maxUnits,
                  decreaseSemanticLabel:
                      context.l10n.hostsEventSuccessStepRoomLayoutDecreaseUnits,
                  increaseSemanticLabel:
                      context.l10n.hostsEventSuccessStepRoomLayoutIncreaseUnits,
                  onChanged: (value) => setState(() {
                    _unitCount = value.toInt();
                    if (_columnCount > _unitCount) _columnCount = _unitCount;
                  }),
                ),
                CatchField.stepper(
                  title: context.l10n.hostsEventSuccessStepRoomLayoutCapacity,
                  contract: capacityContract,
                  value: _unitCapacity,
                  min: minCapacity,
                  max: maxCapacity,
                  decreaseSemanticLabel: context
                      .l10n
                      .hostsEventSuccessStepRoomLayoutDecreaseCapacity,
                  increaseSemanticLabel: context
                      .l10n
                      .hostsEventSuccessStepRoomLayoutIncreaseCapacity,
                  onChanged: (value) =>
                      setState(() => _unitCapacity = value.toInt()),
                ),
                CatchField.stepper(
                  title: context.l10n.hostsEventSuccessStepRoomLayoutColumns,
                  contract: gridContract,
                  value: _columnCount,
                  min: 1,
                  max: maxColumns.clamp(1, _unitCount),
                  decreaseSemanticLabel: context
                      .l10n
                      .hostsEventSuccessStepRoomLayoutDecreaseColumns,
                  increaseSemanticLabel: context
                      .l10n
                      .hostsEventSuccessStepRoomLayoutIncreaseColumns,
                  onChanged: (value) =>
                      setState(() => _columnCount = value.toInt()),
                ),
              ],
            ),
            CatchButton(
              label: context.l10n.hostsEventSuccessStepRoomLayoutSave,
              fullWidth: true,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(
        () => _labelError =
            context.l10n.hostsEventSuccessStepRoomLayoutNameRequired,
      );
      return;
    }
    Navigator.of(context).pop(
      EventSuccessLayout.parametric(
        label: label,
        shape: _shape,
        unitCount: _unitCount,
        unitCapacity: _unitCapacity,
        columnCount: _columnCount,
      ),
    );
  }
}

String _shapeLabel(BuildContext context, EventSuccessLayoutShape shape) =>
    switch (shape) {
      EventSuccessLayoutShape.round =>
        context.l10n.hostsEventSuccessStepRoomLayoutShapeRound,
      EventSuccessLayoutShape.rect =>
        context.l10n.hostsEventSuccessStepRoomLayoutShapeRectangle,
      EventSuccessLayoutShape.row =>
        context.l10n.hostsEventSuccessStepRoomLayoutShapeRow,
      EventSuccessLayoutShape.court =>
        context.l10n.hostsEventSuccessStepRoomLayoutShapeCourt,
      EventSuccessLayoutShape.zone =>
        context.l10n.hostsEventSuccessStepRoomLayoutShapeZone,
    };
