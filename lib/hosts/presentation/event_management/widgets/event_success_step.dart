import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/event_success/event_success.dart'
    show
        EventSuccessController,
        EventSuccessDefaultsPanel,
        EventSuccessRoomSetupSection,
        eventSuccessControllerProvider;
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
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
    final layoutsState = catchAsyncStateFromAsyncValue(layoutsAsync);
    Future<EventSuccessLayout> saveLayout(EventSuccessLayout layout) =>
        EventSuccessController.upsertLayoutMutation.run(
          ref,
          (tx) => tx
              .get(eventSuccessControllerProvider.notifier)
              .upsertLayout(organizerId: organizerId, layout: layout),
        );
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
            if (eventSuccessDefaults.enabled)
              EventSuccessRoomSetupSection(
                layoutsState: layoutsState,
                selectedLayoutId: eventSuccessDefaults.layoutId,
                usesWholeGroup: usesWholeGroup,
                enabled: true,
                isSavingLayout: layoutMutation.isPending,
                saveError: layoutMutation.hasError
                    ? (layoutMutation as MutationError).error
                    : null,
                onSelected: (layoutId) => onEventSuccessDefaultsChanged(
                  eventSuccessDefaults.copyWith(layoutId: layoutId),
                ),
                onSaveLayout: saveLayout,
              ),
          ],
        ),
      ],
    );
  }
}
